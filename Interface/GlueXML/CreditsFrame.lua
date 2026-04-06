
CREDITS_SCROLL_RATE = 40;
CREDITS_FADE_RATE = 0.4;
--CREDITS_MAX_ALPHA = 0.7;
NUM_CREDITS_ART_TEXTURES_WIDE = 4;
NUM_CREDITS_ART_TEXTURES_HIGH = 2;
CACHE_WAIT_TIME = 0.5;

CreditsArtInfo = {};
CreditsArtInfo[1] = { file="Acrest", w=512, h=512, offsetx=128, offsety=0, maxAlpha=0.5 };
CreditsArtInfo[2] = { file="Tauren", w=640, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[3] = { file="Centaur", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[4] = { file="HordeBanner", w=512, h=512, offsetx=128, offsety=0, maxAlpha=0.5 };
--CreditsArtInfo[5] = { file="Lab", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[5] = { file="Naga", w=512, h=512, offsetx=128, offsety=0, maxAlpha=0.4 };
CreditsArtInfo[6] = { file="NightsHollow", w=512, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[7] = { file="Ocean", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[8] = { file="Orc", w=256, h=512, offsetx=192, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[9] = { file="Strangle", w=512, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[10] = { file="Troll", w=640, h=512, offsetx=0, offsety=0, maxAlpha=0.6 };
CreditsArtInfo[11] = { file="TrollBanner", w=512, h=512, offsetx=128, offsety=0, maxAlpha=0.5 };
CreditsArtInfo[12] = { file="Zepplin", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.5 };
CreditsArtInfo[13] = { file="drake", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.5 };
CreditsArtInfo[14] = { file="DwarfCrest", w=512, h=512, offsetx=128, offsety=0, maxAlpha=0.5 };
CreditsArtInfo[15] = { file="Dwarfhunter", w=512, h=512, offsetx=128, offsety=0, maxAlpha=0.6 };
CreditsArtInfo[16] = { file="gargoyle", w=512, h=512, offsetx=128, offsety=0, maxAlpha=0.5 };
CreditsArtInfo[17] = { file="NightelfCrest", w=512, h=512, offsetx=128, offsety=0, maxAlpha=0.5 };
CreditsArtInfo[18] = { file="Nightelves", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[19] = { file="Orccamp", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[20] = { file="DragonIsles", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[21] = { file="tauren_hunter", w=512, h=512, offsetx=128, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[22] = { file="Darnasis", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[23] = { file="ForsakenCrest", w=512, h=512, offsetx=128, offsety=0, maxAlpha=0.5 };
CreditsArtInfo[24] = { file="ShootingDwarf", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.6 };
CreditsArtInfo[25] = { file="Thunderbluff", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[26] = { file="tolbarad", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[27] = { file="TaurenCrest", w=512, h=512, offsetx=128, offsety=0, maxAlpha=0.5 };
CreditsArtInfo[28] = { file="razorfen", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[29] = { file="swampofsorrows", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[30] = { file="Desolace", w=512, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[31] = { file="SouthernDesolace", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[32] = { file="undeadcrest", w=512, h=512, offsetx=128, offsety=0, maxAlpha=0.5 };
CreditsArtInfo[33] = { file="TirisfallGlades", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[34] = { file="ThousandNeedles", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[35] = { file="Elemental", w=512, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[36] = { file="Badlands", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[37] = { file="BlastedLands", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[38] = { file="Fellwood", w=768, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[39] = { file="OrcShield", w=512, h=512, offsetx=128, offsety=0, maxAlpha=0.5 };

function CreditsFrame_OnShow()
	CreditsScrollFrame:SetVerticalScroll(0);
	CreditsScrollFrame:UpdateScrollChildRect();
	CreditsScrollFrame.scroll = 0;
	CreditsScrollFrame.scrollMax = CreditsScrollFrame:GetVerticalScrollRange() + 768;
	this.artCount = getn(CreditsArtInfo);
	this.currentArt = 0;
	this.fadingIn = nil;
	this.fadingOut = nil;
	this.cacheArt = 0;
	this.cacheIndex = 1;
	this.cacheElapsed = 0;
	this.alphaIn = 0;
	this.alphaOut = 0;

	for i=1, NUM_CREDITS_ART_TEXTURES_HIGH, 1 do
		for j=1, NUM_CREDITS_ART_TEXTURES_WIDE, 1 do
			_G["CreditsArtAlt"..(((i - 1) * NUM_CREDITS_ART_TEXTURES_WIDE) + j)]:Hide();
			_G["CreditsArtCache"..(((i - 1) * NUM_CREDITS_ART_TEXTURES_WIDE) + j)]:SetAlpha(0.005);
		end
	end

	CreditsFrame_CacheTextures(2);

	HideCursor();
end

function CreditsFrame_SetArtTextures(textureName, index, alpha)
	local info = CreditsArtInfo[index];
	if ( not info ) then
		return;
	end

	local texture;
	local texIndex = 1;
	local width, height;
	_G[textureName..1]:SetPoint("TOPLEFT", "CreditsFrame", "TOPLEFT", info.offsetx, info.offsety - 128);
	for i=1, NUM_CREDITS_ART_TEXTURES_HIGH, 1 do
		height = info.h - ((i - 1) * 256);
		if ( height > 256 ) then
			height = 256;
		end
		for j=1, NUM_CREDITS_ART_TEXTURES_WIDE, 1 do
			texture = _G[textureName..(((i - 1) * NUM_CREDITS_ART_TEXTURES_WIDE) + j)];
			width = info.w - ((j - 1) * 256);
			if ( width > 256 ) then
				width = 256;
			end
			if ( (width <= 0) or (height <= 0) ) then
				texture:Hide();
			else
				texture:SetTexture("Interface\\Glues\\Credits\\"..info.file..texIndex);
				texture:SetWidth(width);
				texture:SetHeight(height);
				texture:SetAlpha(alpha);
				texture:Show();
				texIndex = texIndex + 1;
			end
		end
	end
end

function CreditsFrame_CacheTextures(index)
	this.cacheArt = index;
	this.cacheIndex = 1;
	this.cacheElapsed = 0;

	local info = CreditsArtInfo[index];
	if ( not info ) then
		return;
	end

	CreditsArtCache1:SetTexture("Interface\\Glues\\Credits\\"..info.file.."1");
end

function CreditsFrame_UpdateCache()
	if ( this.cacheIndex >= (NUM_CREDITS_ART_TEXTURES_WIDE * NUM_CREDITS_ART_TEXTURES_HIGH) ) then
		return;
	end
	if ( this.cacheElapsed < CACHE_WAIT_TIME ) then
		return;
	end

	this.cacheElapsed = this.cacheElapsed - CACHE_WAIT_TIME;
	this.cacheIndex = this.cacheIndex + 1;

	local info = CreditsArtInfo[this.cacheArt];
	if ( not info ) then
		return;
	end

	_G["CreditsArtCache"..this.cacheIndex]:SetTexture("Interface\\Glues\\Credits\\"..info.file..this.cacheIndex);
end

function CreditsFrame_UpdateArt(index, elapsed)
	if (index > (this.currentArt + 1) ) then
		return;
	end

	if ( index == this.currentArt ) then
		if ( this.fadingOut ) then
			this.alphaOut = max(this.alphaOut - (CREDITS_FADE_RATE * elapsed), 0);

			for i=1, NUM_CREDITS_ART_TEXTURES_HIGH, 1 do
				for j=1, NUM_CREDITS_ART_TEXTURES_WIDE, 1 do
					_G["CreditsArtAlt"..(((i - 1) * NUM_CREDITS_ART_TEXTURES_WIDE) + j)]:SetAlpha(this.alphaOut);
				end
			end

			if ( this.alphaOut <= 0 ) then
				this.fadingOut = nil;
				CreditsFrame_CacheTextures(this.currentArt + 1);
			end
		end

		if ( this.fadingIn ) then
			local maxAlpha = CreditsArtInfo[this.currentArt].maxAlpha;
			this.alphaIn = min(this.alphaIn + (CREDITS_FADE_RATE * elapsed), maxAlpha);
			for i=1, NUM_CREDITS_ART_TEXTURES_HIGH, 1 do
				for j=1, NUM_CREDITS_ART_TEXTURES_WIDE, 1 do
					_G["CreditsArt"..(((i - 1) * NUM_CREDITS_ART_TEXTURES_WIDE) + j)]:SetAlpha(this.alphaIn);
				end
			end

			if ( this.alphaIn >= maxAlpha ) then
				this.fadingIn = nil;
			end
		end
		return;
	end

	if ( this.currentArt > 0 ) then
		this.fadingOut = 1;
		this.alphaOut = CreditsArtInfo[this.currentArt].maxAlpha;
		CreditsFrame_SetArtTextures("CreditsArtAlt", this.currentArt, this.alphaOut);
	end

	this.fadingIn = 1;
	this.alphaIn = 0;
	this.currentArt = index;
	CreditsFrame_SetArtTextures("CreditsArt", index, this.alphaIn);
end

function CreditsFrame_OnUpdate(elapsed)
	if ( not CreditsScrollFrame:IsVisible() ) then
		return;
	end

	CreditsScrollFrame.scroll = CreditsScrollFrame.scroll + (CREDITS_SCROLL_RATE * elapsed);
	if ( CreditsScrollFrame.scroll >= CreditsScrollFrame.scrollMax ) then
		SetGlueScreen("login");
		return;
	end

	this.cacheElapsed = this.cacheElapsed + elapsed;
	CreditsFrame_UpdateCache();

	CreditsScrollFrame:SetVerticalScroll(CreditsScrollFrame.scroll);
	CreditsFrame_UpdateArt(ceil(this.artCount * (CreditsScrollFrame.scroll / CreditsScrollFrame.scrollMax)), elapsed);
end

function CreditsFrame_OnScrollRangeChanged()
	CreditsScrollFrame.scrollMax = CreditsScrollFrame:GetVerticalScrollRange() + 768;
end

function CreditsFrame_OnKeyDown()
	if ( arg1 == "ESCAPE" ) then
		SetGlueScreen("login");
	elseif ( arg1 == "PRINTSCREEN" ) then
		Screenshot();
	end
end
