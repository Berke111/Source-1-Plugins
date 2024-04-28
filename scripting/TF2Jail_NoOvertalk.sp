#pragma semicolon 1

#include <basecomm>
#include <morecolors>
#include <sdktools_voice>
#include <tf2jail>

#define strPluginColor "{darkkhaki}"
#define strPluginNameColor "{green}"

bool bIsWardenSpeaking, bIsSpeaking[MAXPLAYERS], bWasMuted[MAXPLAYERS], bOvertalkMute = false;

public Plugin myinfo =
{
	name = "[TF2Jail] No Overtalk",
	author = "Berke, thanks to Semicolon Backslash and worMatty",
	description = "Mutes other players while the Warden is talking.",
	version = "1.1.1"
}

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("TF2Jail.phrases");

	HookEvent("teamplay_round_start", EventOnRoundStart, EventHookMode_PostNoCopy);

	RegConsoleCmd("sm_wot", CommandToggleOvertalk, "Toggle the overtalk mute.");
	RegConsoleCmd("sm_wardenot", CommandToggleOvertalk, "Toggle the overtalk mute.");
	RegConsoleCmd("sm_wovertalk", CommandToggleOvertalk, "Toggle the overtalk mute.");
	RegConsoleCmd("sm_wardenovertalk", CommandToggleOvertalk, "Toggle the overtalk mute.");
}

void EventOnRoundStart(Event eEvent, const char[] strName, bool bDontBroadcast)
{
	bOvertalkMute = false;
}

Action CommandToggleOvertalk(int iClient, int iArguments)
{
	if (!iClient)
		CReplyToCommand(iClient, "%t %t", "plugin tag", "Command is in-game only");

	else if (!TF2Jail_IsWarden(iClient))
		CReplyToCommand(iClient, "%t %t", "plugin tag", "not warden");

	else if (bOvertalkMute)
	{
		CPrintToChatAll("%t %sWarden %s%N %shas disabled Overtalk Mute!", "plugin tag", strPluginColor, strPluginNameColor, iClient, strPluginColor);

		if (IsSpeaking(iClient))
			WardenSpeakingEnd();

		bOvertalkMute = false;
	}

	else
	{
		CPrintToChatAll("%t %sWarden %s%N %shas enabled Overtalk Mute!", "plugin tag", strPluginColor, strPluginNameColor, iClient, strPluginColor);

		bOvertalkMute = true;

		if (IsSpeaking(iClient))
			WardenSpeakingStart();
	}

	return Plugin_Handled;
}

public void OnClientDisconnect(int iClient)
{
	bIsSpeaking[iClient - 1] = false;
}

public void OnMapEnd()
{
	WardenSpeakingEnd();

	for (int iClient; iClient < MAXPLAYERS; iClient++)
		bIsSpeaking[iClient] = bWasMuted[iClient] = false;

	bOvertalkMute = false;
}

public void OnPluginEnd()
{
	WardenSpeakingEnd();
}

public void OnClientSpeaking(int iClient)
{
	if (!IsSpeaking(iClient))
	{
		int iClientMinus = iClient - 1;

		bIsSpeaking[iClientMinus] = true;

		if (IsClientInGame(iClient) && !(GetClientListeningFlags(iClient) & VOICE_MUTED) && !bWasMuted[iClientMinus])
			if (TF2Jail_IsWarden(iClient))
				WardenSpeakingStart();

			else if (bIsWardenSpeaking)
				WardenMuteWarn(iClient);
	}
}

public void OnClientSpeakingEnd(int iClient)
{
	bIsSpeaking[iClient - 1] = false;

	if (IsClientInGame(iClient) && TF2Jail_IsWarden(iClient))
		WardenSpeakingEnd();
}

public void BaseComm_OnClientMute(int iClient)
{
	if (TF2Jail_IsWarden(iClient))
		WardenSpeakingEnd();
}

public void TF2Jail_OnWardenCreated(int iClient)
{
	if (IsSpeaking(iClient))
		WardenSpeakingStart();
}

public void TF2Jail_OnWardenRemoved(int iClient)
{
	WardenSpeakingEnd();
}

bool IsSpeaking(int iClient)
{
	return bIsSpeaking[iClient - 1];
}

void WardenSpeakingStart()
{
	if (bOvertalkMute)
	{
		bIsWardenSpeaking = true;

		for (int iClient = 1; iClient <= MaxClients; iClient++)
			if (IsClientInGame(iClient) && !IsFakeClient(iClient) && !TF2Jail_IsWarden(iClient) && !(GetUserFlagBits(iClient) & ADMFLAG_GENERIC))
			{
				if (IsSpeaking(iClient) && !(GetClientListeningFlags(iClient) & VOICE_MUTED))
					WardenMuteWarn(iClient);

				MuteClient(iClient);
			}
	}
}

void WardenSpeakingEnd()
{
	if (bOvertalkMute && bIsWardenSpeaking)
	{
		bIsWardenSpeaking = false;

		for (int iClient = 1; iClient <= MaxClients; iClient++)
			if (IsClientInGame(iClient) && !IsFakeClient(iClient) && !TF2Jail_IsWarden(iClient))
				UnmuteClient(iClient);
	}
}

void WardenMuteWarn(int iClient)
{
	PrintCenterText(iClient, "You are muted while the Warden is talking.");
}

void MuteClient(int iClient)
{
	if (!BaseComm_IsClientMuted(iClient))
	{
		int iListeningFlags = GetClientListeningFlags(iClient);

		if (iListeningFlags & VOICE_MUTED)
			bWasMuted[iClient - 1] = true;

		else
			SetClientListeningFlags(iClient, iListeningFlags | VOICE_MUTED);
	}
}

void UnmuteClient(int iClient)
{
	if (!BaseComm_IsClientMuted(iClient))
	{
		int iClientMinus = iClient - 1;

		if (bWasMuted[iClientMinus])
			bWasMuted[iClientMinus] = false;

		else
			SetClientListeningFlags(iClient, GetClientListeningFlags(iClient) & ~VOICE_MUTED);
	}
}