dxConstruction:subclass{
	type  = 'bar';
	progress = 0;
	progressSide = 1;
	isEnabled = true;

	create = function( self )
		if not dxConstruction.create( self, false ) then
			return false
		end

		local bar = self.objects.bar

		if not bar then
			self:errorHandler( 'No bar for progressbar' )
			return false
		end

		self.barX = bar.x
		self.barY = bar.y
		self.barMaxW = bar.w
		self.barMaxH = bar.h

		self:setEnabled( self.isEnabled )
		return self
	end;

	setProgress = function( self, progress )
		if type( progress ) == 'number' then
			self.progress = math.clamp( 0, progress, 1 )

			if self.progressSide == 1 then
				
			elseif self.progressSide == 2 then
				self.objects.bar.w = self.barMaxW * progress
			elseif self.progressSide == 3 then
				
			elseif self.progressSide == 4 then
				
			end

			if self.onChanged then
				self:onChanged( progress )
			end
			return true
		end
		return false
	end;

	getProrgess = function( self )
		return self.progress
	end;

	setEnabled = function( self, state )
		if type( state ) == 'boolean' then
			self.isEnabled = state
			return true
		end
		return false
	end;

	getEnabled = function( self )
		return self.isEnabled
	end;

	onClick = function( self, cX, cY )
		if self.isEnabled then
			if self.progressSide == 1 then
				self:setProgress( 1 - (cY - self.y) / self.h )
			elseif self.progressSide == 2 then
				self:setProgress( (cX - self.x) / self.w )
			elseif self.progressSide == 3 then
				self:setProgress( (cY - self.y) / self.h )
			elseif self.progressSide == 4 then
				self:setProgress( 1 - (cX - self.x) / self.w )
			end
		end
	end;
}
