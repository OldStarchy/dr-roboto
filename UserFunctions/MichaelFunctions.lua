local function regMikeFunc(...)
	registerUserFunctionFromFile('programs/MichaelStuff.lua', ...)
end

regMikeFunc('goToGround')
regMikeFunc('quarry', 'maxRadius')
regMikeFunc('concentricSquare', 'maxRadius')
regMikeFunc('square', 'radius')
regMikeFunc('lineDown', 'len')
regMikeFunc('lineUp', 'len')
regMikeFunc('line', 'len')
