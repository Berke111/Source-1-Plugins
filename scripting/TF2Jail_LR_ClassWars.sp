#pragma semicolon 1

#include <morecolors>
#include <tf2_stocks>
#include <tf2jail>

#define strPluginColor "{darkkhaki}"

public Plugin myinfo =
{
	name = "[TF2Jail] LR: Class Wars",
	author = "Berke",
	description = "Class wars last request.",
	version = "1.0.0"
}

public void OnPluginStart()
{
	LoadTranslations("TF2Jail.phrases");
}

public void TF2Jail_OnLastRequestExecute(const char[] strLastRequestName)
{
	if (StrEqual(strLastRequestName, "LR_ClassWars"))
	{
		TFClassType TFCTPrisonerClass = TFClassType:GetRandomInt(1, 9);

		char strPrisonerClass[16];

		GetClassName(TFCTPrisonerClass, strPrisonerClass, sizeof(strPrisonerClass));

		TFClassType TFCTGuardClass = TFClassType:GetRandomInt(1, 9);

		char strGuardClass[16];

		GetClassName(TFCTGuardClass, strGuardClass, sizeof(strGuardClass));

		CPrintToChatAll("%t %sClass wars! %s prisoners versus %s guards!", "plugin tag", strPluginColor, strPrisonerClass, strGuardClass);

		for (int iClient = 1; iClient <= MaxClients; iClient++)
			if (IsClientInGame(iClient) && IsPlayerAlive(iClient))
				if (TF2_GetClientTeam(iClient) == TFTeam_Red)
				{
					if (TF2_GetPlayerClass(iClient) != TFCTPrisonerClass)
					{
						TF2_SetPlayerClass(iClient, TFCTPrisonerClass, _, false);

						TF2_RegeneratePlayer(iClient);
					}
				}

				else if (TF2_GetPlayerClass(iClient) != TFCTGuardClass)
				{
					TF2_SetPlayerClass(iClient, TFCTGuardClass, _, false);

					TF2_RegeneratePlayer(iClient);
				}
	}
}

void GetClassName(TFClassType TFCTCkass, char[] strName, int iSize)
{
	switch (TFCTCkass)
	{
		case TFClass_Scout:
			strcopy(strName, iSize, "Scout");

		case TFClass_Soldier:
			strcopy(strName, iSize, "Soldier");

		case TFClass_Pyro:
			strcopy(strName, iSize, "Pyro");

		case TFClass_DemoMan:
			strcopy(strName, iSize, "Demoman");

		case TFClass_Heavy:
			strcopy(strName, iSize, "Heavy");

		case TFClass_Engineer:
			strcopy(strName, iSize, "Engineer");

		case TFClass_Medic:
			strcopy(strName, iSize, "Medic");

		case TFClass_Sniper:
			strcopy(strName, iSize, "Sniper");

		case TFClass_Spy:
			strcopy(strName, iSize, "Spy");
	}
}