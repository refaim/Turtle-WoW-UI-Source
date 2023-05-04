SECONDS_PER_PULSE = 1;

function GlueButtonMaster_OnUpdate(elapsed)
	if ( getglobal(this:GetName().."Glow"):IsVisible() ) then
		local sign = this.pulseSign;
		local counter;
		
		if ( not this.pulsing ) then
			counter = 0;
			this.pulsing = 1;
			sign = 1;
		else
			counter = this.pulseCounter + (sign * elapsed);
			if ( counter > SECONDS_PER_PULSE ) then
				counter = SECONDS_PER_PULSE;
				sign = -sign;
			elseif ( counter < 0) then
				counter = 0;
				sign = -sign;
			end
		end
		
		local alpha = counter / SECONDS_PER_PULSE;
		getglobal(this:GetName().."Glow"):SetVertexColor(1.0, 1.0, 1.0, alpha);

		this.pulseSign = sign;
		this.pulseCounter = counter;
	end
end
