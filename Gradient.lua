dxGUI.baseClass:subclass{
	type                  = 'gradient';
	colorFrom             = tocolor( 255, 255, 255 );
	colorTo               = tocolor( 0, 0, 0 );
	postgui               = false;
	isHorizontal          = false;
	easing                = 'Linear';

	gradientFunction = function( self, progress )
		local from = self.fromRGB
		local to = self.toRGB
		if not from or not to then
			from = { color.HEXtoRGB( self.colorFrom ) }
			to = { color.HEXtoRGB( self.colorTo ) }
			self.fromRGB = from
			self.toRGB = to
		end
		progress = getEasingValue( progress, self.easing )

		return tocolor( from[1] + ( to[1] - from[1] ) * progress,
			from[2] + ( to[2] - from[2] ) * progress,
			from[3] + ( to[3] - from[3] ) * progress,
			from[4] + ( to[4] - from[4] ) * progress
		)
	end;

	draw = function( self )
		if self.isHorizontal then
			for x = 0, self.w -1 do
				dxDrawRectangle( self.x + x, self.y, 1, self.h, self:gradientFunction( (x+1) / self.w ), self.postgui )
			end
		else
			for y = 0, self.h -1 do
				dxDrawRectangle( self.x, self.y + y, self.w, 1, self:gradientFunction( (y+1) / self.h ), self.postgui )
			end
		end
	end;
}
