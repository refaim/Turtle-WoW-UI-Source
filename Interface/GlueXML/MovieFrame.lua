
MOVIE_CAPTION_FADE_TIME = 1.0;

MovieList = { };
MovieList[1] = { };
MovieList[1][1] = {
	video = "Interface\\Cinematics\\Logo_800"
};
MovieList[1][2] = {
	video = "Interface\\Cinematics\\Logo_1024"
};
MovieList[2] = { };
MovieList[2][1] = {
	video = "Interface\\Cinematics\\WOW_Intro_800"
};
MovieList[2][2] = {
	video = "Interface\\Cinematics\\WOW_Intro_1024"
};

function MovieFrame_PlayMovie(index)
	this.movieIndex = index;
	if ( not MovieList[index] or
			not this:StartMovie(MovieList[index][this.resolution].video) ) then
		this:Hide();
		return;
	end
end

function MovieFrame_PlayNextMovie()
	this:StopMovie();
	MovieFrame_PlayMovie(this.movieIndex + 1);
end

function MovieFrame_OnShow()
	this:EnableSubtitles(GetMovieSubtitles());
	HideCursor();
	MovieFrameSubtitleString:Hide();
	if ( GetMovieResolution() < 1024 ) then
		this.resolution = 1;	-- Low resolution
	else
		this.resolution = 2;	-- High resolution
	end
	MovieFrame_PlayMovie(1);
end

function MovieFrame_OnHide()
	this:StopMovie();
	SetGlueScreen("login");
	ShowCursor();
end

function MovieFrame_OnUpdate(elapsed)
	if ( MovieFrameSubtitleString:IsVisible() and this.fadingAlpha ) then
		this.fadingAlpha = this.fadingAlpha + ((elapsed / this.fadeSpeed) * this.fadeDirection);
		if ( this.fadingAlpha > 1.0 ) then
			MovieFrameSubtitleString:SetAlpha(1.0);
			this.fadingAlpha = nil;
		elseif ( this.fadingAlpha <= 0.0 ) then
			MovieFrameSubtitleString:Hide();
			this.fadingAlpha = nil;
		else
			MovieFrameSubtitleString:SetAlpha(this.fadingAlpha);
		end
	end
end

function MovieFrame_OnKeyUp()
	if ( arg1 == "ESCAPE" ) then
		this:Hide();
	elseif ( arg1 == "SPACE" or arg1 == "ENTER" ) then
		this:StopMovie();
	end
end

function MovieFrame_OnMovieFinished()
	if ( this:IsVisible() ) then
		MovieFrame_PlayNextMovie();
	end
end

function MovieFrame_OnMovieShowSubtitle(text)
	MovieFrameSubtitleString:SetText(text);
	MovieFrameSubtitleString:Show();
	this.fadingAlpha = 0.0;
	this.fadeDirection = 1.0;
	this.fadeSpeed = MOVIE_CAPTION_FADE_TIME;
	MovieFrameSubtitleString:SetAlpha(this.fadingAlpha);
end

function MovieFrame_OnMovieHideSubtitle()
	this.fadingAlpha = 1.0;
	this.fadeDirection = -1.0;
	this.fadeSpeed = MOVIE_CAPTION_FADE_TIME / 2;
	MovieFrameSubtitleString:SetAlpha(this.fadingAlpha);
end

