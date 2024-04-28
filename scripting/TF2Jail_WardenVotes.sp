#pragma semicolon 1

#include <morecolors>
#include <tf2_stocks>
#include <tf2jail>

#define strPluginColor "{darkkhaki}"
#define strPluginNameColor "{green}"
#define iVoteDuration 10
#define iVoteCooldown 5

float flLastVoteUsage;

char strGlobalTitle[256];

public Plugin myinfo =
{
	name = "[TF2Jail] Warden Votes",
	author = "Berke",
	description = "Allows the Warden to create votes.",
	version = "1.1.0"
}

public void OnPluginStart()
{
	LoadTranslations("basevotes.phrases");
	LoadTranslations("common.phrases");
	LoadTranslations("TF2Jail.phrases");

	HookEvent("teamplay_round_start", EventOnRoundStart, EventHookMode_PostNoCopy);

	RegConsoleCmd("sm_wvote", CommandWardenVote, "Create a vote as the Warden.");
	RegConsoleCmd("sm_wardenvote", CommandWardenVote, "Create a vote as the Warden.");
	RegConsoleCmd("sm_wbluevote", CommandWardenVoteBlue, "Create a vote as the Warden for the blue team.");
	RegConsoleCmd("sm_wardenbluevote", CommandWardenVoteBlue, "Create a vote as the Warden for the blue team.");
	RegConsoleCmd("sm_wredvote", CommandWardenVoteRed, "Create a vote as the Warden for the red team.");
	RegConsoleCmd("sm_wardenredvote", CommandWardenVoteRed, "Create a vote as the Warden for the red team.");
}

void EventOnRoundStart(Event eEvent, const char[] strName, bool bDontBroadcast)
{
	flLastVoteUsage = 0.0;
}

public void OnMapEnd()
{
	flLastVoteUsage = 0.0, strGlobalTitle = "";
}

Action CommandWardenVote(int iClient, int iArguments)
{
	switch (StartWardenVote(iClient, iArguments))
	{
		case 1:
			CReplyToCommand(iClient, "%t %t", "plugin tag", "Command is in-game only");

		case 2:
			CReplyToCommand(iClient, "%t %t", "plugin tag", "not warden");

		case 3:
			CReplyToCommand(iClient, "%t %s%t", "plugin tag", strPluginColor, "Vote in Progress");

		case 4:
		{
			int iOffCooldown = RoundToCeil(flLastVoteUsage + float(iVoteCooldown) - GetGameTime());

			if (iOffCooldown == 1)
				CReplyToCommand(iClient, "%t %sWarden vote is on cooldown for 1 second.", "plugin tag", strPluginColor);

			else
				CReplyToCommand(iClient, "%t %sWarden vote is on cooldown for %i seconds.", "plugin tag", strPluginColor, iOffCooldown);
		}
	}

	return Plugin_Handled;
}

Action CommandWardenVoteBlue(int iClient, int iArguments)
{
	switch (StartWardenVote(iClient, iArguments, view_as<int>(TFTeam_Blue)))
	{
		case 1:
			CReplyToCommand(iClient, "%t %t", "plugin tag", "Command is in-game only");

		case 2:
			CReplyToCommand(iClient, "%t %t", "plugin tag", "not warden");

		case 3:
			CReplyToCommand(iClient, "%t %s%t", "plugin tag", strPluginColor, "Vote in Progress");

		case 4:
		{
			int iOffCooldown = RoundToCeil(flLastVoteUsage + float(iVoteCooldown) - GetGameTime());

			if (iOffCooldown == 1)
				CReplyToCommand(iClient, "%t %sWarden vote is on cooldown for 1 second.", "plugin tag", strPluginColor);

			else
				CReplyToCommand(iClient, "%t %sWarden vote is on cooldown for %i seconds.", "plugin tag", strPluginColor, iOffCooldown);
		}
	}

	return Plugin_Handled;
}

Action CommandWardenVoteRed(int iClient, int iArguments)
{
	switch (StartWardenVote(iClient, iArguments, view_as<int>(TFTeam_Red)))
	{
		case 1:
			CReplyToCommand(iClient, "%t %t", "plugin tag", "Command is in-game only");

		case 2:
			CReplyToCommand(iClient, "%t %t", "plugin tag", "not warden");

		case 3:
			CReplyToCommand(iClient, "%t %s%t", "plugin tag", strPluginColor, "Vote in Progress");

		case 4:
		{
			int iOffCooldown = RoundToCeil(flLastVoteUsage + float(iVoteCooldown) - GetGameTime());

			if (iOffCooldown == 1)
				CReplyToCommand(iClient, "%t %sWarden vote is on cooldown for 1 second.", "plugin tag", strPluginColor);

			else
				CReplyToCommand(iClient, "%t %sWarden vote is on cooldown for %i seconds.", "plugin tag", strPluginColor, iOffCooldown);
		}
	}

	return Plugin_Handled;
}

int StartWardenVote(int iClient, int iArguments, int iTeam = 0)
{
	int iStatus;

	if (!iClient)
		iStatus = 1;

	else if (!TF2Jail_IsWarden(iClient))
		iStatus = 2;

	else if (IsVoteInProgress())
		iStatus = 3;

	else if (flLastVoteUsage + float(iVoteCooldown) > GetGameTime())
		iStatus = 4;

	else
	{
		Menu mMenu = new Menu(WardenVote, MENU_ACTIONS_ALL);

		char strQuestionPiece[32];

		if (iTeam)
		{
			if (iTeam == view_as<int>(TFTeam_Blue))
				strQuestionPiece = " to the blue team";

			else
				strQuestionPiece = " to the red team";
		}

		char strTitle[256];

		if (iArguments)
			GetCmdArg(1, strTitle, sizeof(strTitle));

		if (strlen(strTitle))
		{
			GetCmdArg(1, strTitle, sizeof(strTitle));

			SentenceGrammar(strTitle, strTitle, sizeof(strTitle), true);

			Format(strTitle, sizeof(strTitle), "\"%s\"", strTitle);

			mMenu.SetTitle("Warden %N asks %s.", iClient, strTitle);

			strcopy(strGlobalTitle, sizeof(strGlobalTitle), strTitle);

			CPrintToChatAll("%t %sWarden %s%N %sasks %s%s.", "plugin tag", strPluginColor, strPluginNameColor, iClient, strPluginColor, strTitle, strQuestionPiece);
		}

		else
		{
			mMenu.SetTitle("Warden %N asks.", iClient, strTitle);

			CPrintToChatAll("%t %sWarden %s%N %sasks%s.", "plugin tag", strPluginColor, strPluginNameColor, iClient, strPluginColor, strQuestionPiece);
		}

		if (iArguments <= 2)
		{
			mMenu.AddItem("", "Yes");
			mMenu.AddItem("NoAnswer", "No");
		}

		else
			for (int iCurrentArgument = 2; iCurrentArgument <= iArguments; iCurrentArgument++)
			{
				char strArgument[256];

				GetCmdArg(iCurrentArgument, strArgument, sizeof(strArgument));

				if (strlen(strArgument))
				{
					SentenceGrammar(strArgument, strArgument, sizeof(strArgument));

					mMenu.AddItem("", strArgument);
				}
			}

		if (iTeam)
		{
			int[] iLocalClients = new int[MaxClients];

			int iCount;

			for (int iLocalClient = 1; iLocalClient <= MaxClients; iLocalClient++)
				if (IsClientInGame(iLocalClient) && TF2_GetClientTeam(iLocalClient) == view_as<TFTeam>(iTeam) && IsPlayerAlive(iLocalClient))
					iLocalClients[iCount++] = iLocalClient;

			mMenu.DisplayVote(iLocalClients, iCount, iVoteDuration);
		}

		else
			mMenu.DisplayVoteToAll(iVoteDuration);
	}

	return iStatus;
}

int WardenVote(Menu mMenu, MenuAction maAction, int iParameter1, int iParameter2)
{
	int iStatus, iNoVotes;

	if (iParameter1 == VoteCancel_NoVotes)
		iNoVotes++;

	switch (maAction)
	{
		case MenuAction_DisplayItem:
		{
			char strAnswer[256];

			mMenu.GetItem(iParameter2, "", 0, _, strAnswer, sizeof(strAnswer));

		 	if (!strcmp(strAnswer, "Yes") || !strcmp(strAnswer, "No"))
		 	{
				Format(strAnswer, sizeof(strAnswer), "%T", strAnswer, iParameter1);

				iStatus = RedrawMenuItem(strAnswer);
			}
		}

		case MenuAction_VoteCancel:
			iNoVotes++;

		case MenuAction_VoteEnd:
		{
			flLastVoteUsage = GetGameTime();

			char strAnswer[256], strAnswerDisplay[256];

			mMenu.GetItem(iParameter1, strAnswer, sizeof(strAnswer), _, strAnswerDisplay, sizeof(strAnswerDisplay));

			int iVotes, iTotalVotes;

			GetMenuVoteInfo(iParameter2, iVotes, iTotalVotes);

			if (!strcmp(strAnswer, "NoAnswer") && iParameter1 == 1)
				CPrintToChatAll("%t %s%t", "plugin tag", strPluginColor, "Vote Failed", 50, RoundToNearest(100.0 * float(iTotalVotes - iVotes) / float(iTotalVotes)), iTotalVotes);

			else
				CPrintToChatAll("%t %s%t", "plugin tag", strPluginColor, "Vote Successful", RoundToNearest(100.0 * float(iVotes) / float(iTotalVotes)), iTotalVotes);

			if (!strcmp(strAnswerDisplay, "Yes") || !strcmp(strAnswerDisplay, "No"))
			{
				for (int iClient = 1; iClient <= MaxClients; iClient++)
				{
					char strTranslatedAnswerDisplay[256];

					if (IsClientInGame(iClient) && !IsFakeClient(iClient))
					{
						Format(strTranslatedAnswerDisplay, sizeof(strTranslatedAnswerDisplay), "\"%T\"", strAnswerDisplay, iClient);

						CPrintToChat(iClient, "%t %s%t", "plugin tag", strPluginColor, "Vote End", strGlobalTitle, strTranslatedAnswerDisplay);
					}
				}
			}

			else
			{
				Format(strAnswerDisplay, sizeof(strAnswerDisplay), "\"%s\"", strAnswerDisplay);

				CPrintToChatAll("%t %s%t", "plugin tag", strPluginColor, "Vote End", strGlobalTitle, strAnswerDisplay);
			}

			strGlobalTitle = "";
		}
	}

	if (iNoVotes == 2)
	{
		flLastVoteUsage = GetGameTime();

		CPrintToChatAll("%t %s%t", "plugin tag", strPluginColor, "No Votes Cast");
	}

	return iStatus;
}

void SentenceGrammar(char[] strSentence, char[] strDestination, int iMaxlength, bool bIsQuestion = false)
{
	for (int iLength = strlen(strSentence), iLetterOrder; iLetterOrder < iLength; iLetterOrder++)
	{
		int iLetter = strSentence[iLetterOrder];

		if (iLetter != '?')
		{
			if (bIsQuestion && iLetterOrder == iLength - 1)
				Format(strSentence, iMaxlength, "%s?", strSentence);

			if (iLetterOrder)
				strSentence[iLetterOrder] = CharToLower(iLetter);

			else
				strSentence[iLetterOrder] = CharToUpper(iLetter);
		}
	}

	strcopy(strDestination, iMaxlength, strSentence);
}