FADE_IN_TIME = 2;

function PatchDownload_OnLoad()
	this:SetSequence(0);
	this:SetCamera(0);

	this:RegisterEvent("PATCH_UPDATE_PROGRESS");
	this:RegisterEvent("PATCH_DOWNLOADED");
end

function PatchDownload_OnShow()
	CurrentGlueMusic = "Sound\\Music\\GlueScreenMusic\\wow_main_theme.mp3";
	PatchDownload_UpdateProgress();
	PatchDownload_UpdateButtons();
	PatchDownloadRestartButton:Enable();
end

function PatchDownload_UpdateButtons()
	local amtComplete = PatchDownloadProgress();
	if (amtComplete >= 1.0) then
		PatchDownloadCancelButton:Hide();
		PatchDownloadRestartButton:Show();
		PatchProgressText:Hide();
		PatchSuccessfulText:Show();
		PatchSuccessfulTitle:Show();
		DownloadingUpdateTitle:Hide();
	else
		PatchDownloadCancelButton:Show();
		PatchDownloadRestartButton:Hide();
		PatchProgressText:Show();
		PatchSuccessfulText:Hide();
		PatchSuccessfulTitle:Hide();
		DownloadingUpdateTitle:Show();
	end
end

function PatchDownload_OnKeyDown()
	if ( arg1 == "ESCAPE" ) then
		if ( PatchDownloadCancelButton:IsVisible() ) then
			PatchDownload_Cancel();
		end
	elseif ( arg1 == "ENTER" ) then
		if ( PatchDownloadRestartButton:IsVisible() ) then
			PatchDownload_Restart();
		end
	elseif ( arg1 == "PRINTSCREEN" ) then
		Screenshot();
	end
end

function PatchDownload_UpdateProgress()
	local amtComplete = PatchDownloadProgress();
	PatchProgressText:SetText(format(TEXT("%3.0f%%"), amtComplete*100));
end

function PatchDownload_PatchDownloaded()
	PatchDownload_UpdateButtons();
	PatchDownload_UpdateProgress();
end

function PatchDownload_OnEvent()
	if ( event == "PATCH_UPDATE_PROGRESS" ) then
		PatchDownload_UpdateProgress();
	elseif ( event == "PATCH_DOWNLOADED" ) then
		PatchDownload_PatchDownloaded()
	end
end

function PatchDownload_Cancel()
	PatchDownloadCancel();
end

function PatchDownload_Restart()
	PatchDownloadRestartButton:Disable();
	PatchDownloadApply();
end