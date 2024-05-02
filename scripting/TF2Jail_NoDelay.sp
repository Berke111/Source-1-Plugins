#pragma semicolon 1

#include <morecolors>
#include <tf2jail>

#define strPluginColor "{darkkhaki}"

bool bIsPreventDelayRound = true;

Handle hWardenLockTimer, hWardenLockCommandTimer;

ConVar cvWardenLockTimer, cvWardenLockCommand, cvWardenLockCommandTimer;

public Plugin myinfo =
{
	name = "[TF2Jail] No Delay",
	author = "Berke",
	description = "Prevent the delaying of the round.",
	version = "1.0.1"
}

public void OnPluginStart()
{
	LoadTranslations("TF2Jail.phrases");

	HookEvent("teamplay_round_start", EventOnRoundStart, EventHookMode_PostNoCopy);
	HookEvent("teamplay_round_win", EventOnRoundWin, EventHookMode_PostNoCopy);

	cvWardenLockTimer = FindConVar("sm_tf2jail_warden_timer");
	cvWardenLockCommand = CreateConVar("sm_tf2jail_warden_lock_execute", "sm_slay @blue", "Commands to execute to server on Warden lock: (Maximum Characters: 64)", FCVAR_NOTIFY);
	cvWardenLockCommandTimer = CreateConVar("sm_tf2jail_warden_lock_command_timer", "180", "Time in seconds after Warden is locked to prevent delaying: (0 = instant, NON-FLOAT VALUE)", FCVAR_NOTIFY, true, 0.0);
}

void EventOnRoundStart(Event eEvent, const char[] strName, bool bDontBroadcast)
{
	bIsPreventDelayRound = true;

	DeleteValidHandle(hWardenLockTimer);

	DeleteValidHandle(hWardenLockCommandTimer);
}

public void TF2Jail_OnLastRequestExecute(const char[] strLastRequest)
{
	bIsPreventDelayRound =
	StrEqual(strLastRequest, "LR_PersonalFreeday") ||
	StrEqual(strLastRequest, "LR_FreedayForClients") ||
	StrEqual(strLastRequest, "LR_GuardsMeleeOnly") ||
	StrEqual(strLastRequest, "LR_Custom");
}

void EventOnRoundWin(Event eEvent, const char[] strName, bool bDontBroadcast)
{
	bIsPreventDelayRound = true;

	DeleteValidHandle(hWardenLockTimer);

	DeleteValidHandle(hWardenLockCommandTimer);
}

public void OnMapEnd()
{
	bIsPreventDelayRound = true;

	DeleteValidHandle(hWardenLockTimer);

	DeleteValidHandle(hWardenLockCommandTimer);
}

public void TF2Jail_OnWardenCreated(int iClient)
{
	DeleteValidHandle(hWardenLockTimer);

	DeleteValidHandle(hWardenLockCommandTimer);
}

public void TF2Jail_OnWardenRemoved(int iClient)
{
	if (bIsPreventDelayRound)
	{
		int iWardenLockTimer = GetConVarInt(cvWardenLockTimer);

		if (iWardenLockTimer)
			hWardenLockTimer = CreateTimer(float(iWardenLockTimer), OnWardenLockTimer, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

Action OnWardenLockTimer(Handle hTimer)
{
	int iWardenLockTimer = GetConVarInt(cvWardenLockTimer);

	if (iWardenLockTimer > 0)
	{
		int iWardenLockCommandTimer = GetConVarInt(cvWardenLockCommandTimer);

		if (iWardenLockCommandTimer == 1)
			CPrintToChatAll("%t %sWarden has been locked, preventing delaying in 1 second.", "plugin tag", strPluginColor);

		else
			CPrintToChatAll("%t %sWarden has been locked, preventing delaying in %i seconds.", "plugin tag", strPluginColor, iWardenLockCommandTimer);

		hWardenLockCommandTimer = CreateTimer(float(iWardenLockCommandTimer), OnWardenLockCommandTimer, _, TIMER_FLAG_NO_MAPCHANGE);
	}

	else
		OnWardenLockCommand();

	CloseHandle(hWardenLockTimer);

	return Plugin_Continue;
}

Action OnWardenLockCommandTimer(Handle hTimer)
{
	OnWardenLockCommand();

	CloseHandle(hWardenLockCommandTimer);

	return Plugin_Continue;
}

void OnWardenLockCommand()
{
	CPrintToChatAll("%t %sPrevented delaying due to Warden lock.", "plugin tag", strPluginColor);

	char strCommand[64];

	GetConVarString(cvWardenLockCommand, strCommand, sizeof(strCommand));

	ServerCommand(strCommand);
}

void DeleteValidHandle(Handle hHandle)
{
	if (IsValidHandle(hHandle))
		CloseHandle(hHandle);

	hHandle = null;
}
