--
-- Adapted from
-- Tweener's easing functions (Penner's Easing Equations)
-- and http://code.google.com/p/tweener/ (jstweener javascript version)
--

--[[
Disclaimer for Robert Penner's Easing Equations license:

TERMS OF USE - EASING EQUATIONS

Open source under the BSD License.

Copyright © 2001 Robert Penner
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of the author nor the names of contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

-- For all easing functions:
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration (total time)

EasingType = {
  LINEAR = 1,
  IN_QUAD = 2,
  OUT_QUAD = 3,
  IN_OUT_QUAD = 4,
  OUT_IN_QUAD = 5,
  IN_CUBIC = 6,
  OUT_CUBIC = 7,
  IN_OUT_CUBIC = 8,
  OUT_IN_CUBIC = 9,
  IN_QUART = 10,
  OUT_QUART = 11,
  IN_OUT_QUART = 12,
  OUT_IN_QUART = 13,
  IN_QUINT = 14,
  OUT_QUINT = 15,
  IN_OUT_QUINT = 16,
  OUT_IN_QUINT = 17,
  IN_SIN = 18,
  OUT_SIN = 19,
  IN_OUT_SIN = 20,
  OUT_IN_SIN = 21,
  IN_EXPO = 22,
  OUT_EXPO = 23,
  IN_OUT_EXPO = 24,
  OUT_IN_EXPO = 25,
  IN_CIRCLE = 26,
  OUT_CIRCLE = 27,
  IN_OUT_CIRCLE = 28,
  OUT_IN_CIRCLE = 29,
  IN_ELASTIC = 30,
  OUT_ELASTIC = 31,
  IN_OUT_ELASTIC = 32,
  OUT_IN_ELASTIC = 33,
  IN_BACK = 34,
  OUT_BACK = 35,
  IN_OUT_BACK = 36,
  OUT_IN_BACK = 37,
  OUT_BOUNCE = 38,
  IN_BOUNCE = 39,
  IN_OUT_BOUNCE = 40,
  OUT_IN_BOUNCE = 41
}

function getEasingFunction(type)
  local f = easing()
  if (type == EasingType.LINEAR) then
    return f.linear
  elseif (type == EasingType.IN_QUAD) then
    return f.inQuad
  elseif (type == EasingType.OUT_QUAD) then
    return f.outQuad
  elseif (type == EasingType.IN_OUT_QUAD) then
    return f.inOutQuad
  elseif (type == EasingType.OUT_IN_QUAD) then
    return f.outInQuad
  elseif (type == EasingType.IN_CUBIC) then
    return f.inCubic
  elseif (type == EasingType.OUT_CUBIC) then
    return f.outCubic
  elseif (type == EasingType.IN_OUT_CUBIC) then
    return f.inOutCubic
  elseif (type == EasingType.OUT_IN_CUBIC) then
    return f.outInCubic
  elseif (type == EasingType.IN_QUART) then
    return f.inQuart
  elseif (type == EasingType.OUT_QUART) then
    return f.outQuart
  elseif (type == EasingType.IN_OUT_QUART) then
    return f.inOutQuart
  elseif (type == EasingType.OUT_IN_QUART) then
    return f.outInQuart
  elseif (type == EasingType.IN_QUINT) then
    return f.inQuint
  elseif (type == EasingType.OUT_QUINT) then
    return f.outQuint
  elseif (type == EasingType.IN_OUT_QUINT) then
    return f.inOutQuint
  elseif (type == EasingType.OUT_IN_QUINT) then
    return f.outInQuint
  elseif (type == EasingType.IN_SIN) then
    return f.inSine
  elseif (type == EasingType.OUT_SIN) then
    return f.outSine
  elseif (type == EasingType.IN_OUT_SIN) then
    return f.inOutSine
  elseif (type == EasingType.OUT_IN_SIN) then
    return f.outInSine
  elseif (type == EasingType.IN_EXPO) then
    return f.inExpo
  elseif (type == EasingType.OUT_EXPO) then
    return f.outExpo
  elseif (type == EasingType.IN_OUT_EXPO) then
    return f.inOutExpo
  elseif (type == EasingType.OUT_IN_EXPO) then
    return f.outInExpo
  elseif (type == EasingType.IN_CIRCLE) then
    return f.inCirc
  elseif (type == EasingType.OUT_CIRCLE) then
    return f.outCirc
  elseif (type == EasingType.IN_OUT_CIRCLE) then
    return f.inOutCirc
  elseif (type == EasingType.OUT_IN_CIRCLE) then
    return f.outInCirc
  elseif (type == EasingType.IN_ELASTIC) then
    return f.inElastic
  elseif (type == EasingType.OUT_ELASTIC) then
    return f.outElastic
  elseif (type == EasingType.IN_OUT_ELASTIC) then
    return f.inOutElastic
  elseif (type == EasingType.OUT_IN_ELASTIC) then
    return f.outInElastic
  elseif (type == EasingType.IN_BACK) then
    return f.inBack
  elseif (type == EasingType.OUT_BACK) then
    return f.outBack
  elseif (type == EasingType.IN_OUT_BACK) then
    return f.inOutBack
  elseif (type == EasingType.OUT_IN_BACK) then
    return f.outInBack
  elseif (type == EasingType.OUT_BOUNCE) then
    return f.outBounce
  elseif (type == EasingType.IN_BOUNCE) then
    return f.inBounce
  elseif (type == EasingType.IN_OUT_BOUNCE) then
    return f.inOutBounce
  elseif (type == EasingType.OUT_IN_BOUNCE) then
    return f.outInBounce
  end
end

function easing()

  local sin = math.sin
  local cos = math.cos
  local pi = math.pi
  local sqrt = math.sqrt
  local abs = math.abs
  local asin  = math.asin

  function pow(num, pow)
  	return num^pow
  end

  local function linear(t, b, c, d)
    return c * t / d + b
  end

  local function inQuad(t, b, c, d)
    t = t / d
    return c * pow(t, 2) + b
  end

  local function outQuad(t, b, c, d)
    t = t / d
    return -c * t * (t - 2) + b
  end

  local function inOutQuad(t, b, c, d)
    t = t / d * 2
    if t < 1 then
      return c / 2 * pow(t, 2) + b
    else
      return -c / 2 * ((t - 1) * (t - 3) - 1) + b
    end
  end

  local function outInQuad(t, b, c, d)
    if t < d / 2 then
      return outQuad (t * 2, b, c / 2, d)
    else
      return inQuad((t * 2) - d, b + c / 2, c / 2, d)
    end
  end

  local function inCubic (t, b, c, d)
    t = t / d
    return c * pow(t, 3) + b
  end

  local function outCubic(t, b, c, d)
    t = t / d - 1
    return c * (pow(t, 3) + 1) + b
  end

  local function inOutCubic(t, b, c, d)
    t = t / d * 2
    if t < 1 then
      return c / 2 * t * t * t + b
    else
      t = t - 2
      return c / 2 * (t * t * t + 2) + b
    end
  end

  local function outInCubic(t, b, c, d)
    if t < d / 2 then
      return outCubic(t * 2, b, c / 2, d)
    else
      return inCubic((t * 2) - d, b + c / 2, c / 2, d)
    end
  end

  local function inQuart(t, b, c, d)
    t = t / d
    return c * pow(t, 4) + b
  end

  local function outQuart(t, b, c, d)
    t = t / d - 1
    return -c * (pow(t, 4) - 1) + b
  end

  local function inOutQuart(t, b, c, d)
    t = t / d * 2
    if t < 1 then
      return c / 2 * pow(t, 4) + b
    else
      t = t - 2
      return -c / 2 * (pow(t, 4) - 2) + b
    end
  end

  local function outInQuart(t, b, c, d)
    if t < d / 2 then
      return outQuart(t * 2, b, c / 2, d)
    else
      return inQuart((t * 2) - d, b + c / 2, c / 2, d)
    end
  end

  local function inQuint(t, b, c, d)
    t = t / d
    return c * pow(t, 5) + b
  end

  local function outQuint(t, b, c, d)
    t = t / d - 1
    return c * (pow(t, 5) + 1) + b
  end

  local function inOutQuint(t, b, c, d)
    t = t / d * 2
    if t < 1 then
      return c / 2 * pow(t, 5) + b
    else
      t = t - 2
      return c / 2 * (pow(t, 5) + 2) + b
    end
  end

  local function outInQuint(t, b, c, d)
    if t < d / 2 then
      return outQuint(t * 2, b, c / 2, d)
    else
      return inQuint((t * 2) - d, b + c / 2, c / 2, d)
    end
  end

  local function inSine(t, b, c, d)
    return -c * cos(t / d * (pi / 2)) + c + b
  end

  local function outSine(t, b, c, d)
    return c * sin(t / d * (pi / 2)) + b
  end

  local function inOutSine(t, b, c, d)
    return -c / 2 * (cos(pi * t / d) - 1) + b
  end

  local function outInSine(t, b, c, d)
    if t < d / 2 then
      return outSine(t * 2, b, c / 2, d)
    else
      return inSine((t * 2) -d, b + c / 2, c / 2, d)
    end
  end

  local function inExpo(t, b, c, d)
    if t == 0 then
      return b
    else
      return c * pow(2, 10 * (t / d - 1)) + b - c * 0.001
    end
  end

  local function outExpo(t, b, c, d)
    if t == d then
      return b + c
    else
      return c * 1.001 * (-pow(2, -10 * t / d) + 1) + b
    end
  end

  local function inOutExpo(t, b, c, d)
    if t == 0 then return b end
    if t == d then return b + c end
    t = t / d * 2
    if t < 1 then
      return c / 2 * pow(2, 10 * (t - 1)) + b - c * 0.0005
    else
      t = t - 1
      return c / 2 * 1.0005 * (-pow(2, -10 * t) + 2) + b
    end
  end

  local function outInExpo(t, b, c, d)
    if t < d / 2 then
      return outExpo(t * 2, b, c / 2, d)
    else
      return inExpo((t * 2) - d, b + c / 2, c / 2, d)
    end
  end

  local function inCirc(t, b, c, d)
    t = t / d
    return(-c * (sqrt(1 - pow(t, 2)) - 1) + b)
  end

  local function outCirc(t, b, c, d)
    t = t / d - 1
    return(c * sqrt(1 - pow(t, 2)) + b)
  end

  local function inOutCirc(t, b, c, d)
    t = t / d * 2
    if t < 1 then
      return -c / 2 * (sqrt(1 - t * t) - 1) + b
    else
      t = t - 2
      return c / 2 * (sqrt(1 - t * t) + 1) + b
    end
  end

  local function outInCirc(t, b, c, d)
    if t < d / 2 then
      return outCirc(t * 2, b, c / 2, d)
    else
      return inCirc((t * 2) - d, b + c / 2, c / 2, d)
    end
  end

  local function inElastic(t, b, c, d, a, p)
    if t == 0 then return b end

    t = t / d

    if t == 1  then return b + c end

    if not p then p = d * 0.3 end

    local s

    if not a or a < abs(c) then
      a = c
      s = p / 4
    else
      s = p / (2 * pi) * asin(c/a)
    end

    t = t - 1

    return -(a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
  end

  -- a: amplitud
  -- p: period
  local function outElastic(t, b, c, d)
    if t == 0 then return b end

    p = d*0.3
    a = c
    t = t / d

    if t == 1 then return b + c end

    if not p then p = d * 0.3 end

    local s

    if not a or a < abs(c) then
      a = c
      s = p / 4
    else
      s = p / (2 * pi) * asin(c/a)
    end

    return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p) + c + b
  end

  -- p = period
  -- a = amplitud
  local function inOutElastic(t, b, c, d)
    if t == 0 then return b end

    p = d*(0.3*1.5)
    a = c
    t = t / d * 2

    if t == 2 then return b + c end

    if not p then p = d * (0.3 * 1.5) end
    if not a then a = 0 end

    local s

    if not a or a < abs(c) then
      a = c
      s = p / 4
    else
      s = p / (2 * pi) * asin(c / a)
    end

    if t < 1 then
      t = t - 1
      return -0.5 * (a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
    else
      t = t - 1
      return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p ) * 0.5 + c + b
    end
  end

  -- a: amplitud
  -- p: period
  local function outInElastic(t, b, c, d, a, p)
    if t < d / 2 then
      return outElastic(t * 2, b, c / 2, d, a, p)
    else
      return inElastic((t * 2) - d, b + c / 2, c / 2, d, a, p)
    end
  end

  local function inBack(t, b, c, d, s)
    if not s then s = 1.70158 end
    t = t / d
    return c * t * t * ((s + 1) * t - s) + b
  end

  local function outBack(t, b, c, d, s)
    if not s then s = 1.70158 end
    t = t / d - 1
    return c * (t * t * ((s + 1) * t + s) + 1) + b
  end

  local function inOutBack(t, b, c, d, s)
    if not s then s = 1.70158 end
    s = s * 1.525
    t = t / d * 2
    if t < 1 then
      return c / 2 * (t * t * ((s + 1) * t - s)) + b
    else
      t = t - 2
      return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
    end
  end

  local function outInBack(t, b, c, d, s)
    if t < d / 2 then
      return outBack(t * 2, b, c / 2, d, s)
    else
      return inBack((t * 2) - d, b + c / 2, c / 2, d, s)
    end
  end

  local function outBounce(t, b, c, d)
    t = t / d
    if t < 1 / 2.75 then
      return c * (7.5625 * t * t) + b
    elseif t < 2 / 2.75 then
      t = t - (1.5 / 2.75)
      return c * (7.5625 * t * t + 0.75) + b
    elseif t < 2.5 / 2.75 then
      t = t - (2.25 / 2.75)
      return c * (7.5625 * t * t + 0.9375) + b
    else
      t = t - (2.625 / 2.75)
      return c * (7.5625 * t * t + 0.984375) + b
    end
  end

  local function inBounce(t, b, c, d)
    return c - outBounce(d - t, 0, c, d) + b
  end

  local function inOutBounce(t, b, c, d)
    if t < d / 2 then
      return inBounce(t * 2, 0, c, d) * 0.5 + b
    else
      return outBounce(t * 2 - d, 0, c, d) * 0.5 + c * .5 + b
    end
  end

  local function outInBounce(t, b, c, d)
    if t < d / 2 then
      return outBounce(t * 2, b, c / 2, d)
    else
      return inBounce((t * 2) - d, b + c / 2, c / 2, d)
    end
  end

  return {
    linear = linear,
    inQuad = inQuad,
    outQuad = outQuad,
    inOutQuad = inOutQuad,
    outInQuad = outInQuad,
    inCubic  = inCubic ,
    outCubic = outCubic,
    inOutCubic = inOutCubic,
    outInCubic = outInCubic,
    inQuart = inQuart,
    outQuart = outQuart,
    inOutQuart = inOutQuart,
    outInQuart = outInQuart,
    inQuint = inQuint,
    outQuint = outQuint,
    inOutQuint = inOutQuint,
    outInQuint = outInQuint,
    inSine = inSine,
    outSine = outSine,
    inOutSine = inOutSine,
    outInSine = outInSine,
    inExpo = inExpo,
    outExpo = outExpo,
    inOutExpo = inOutExpo,
    outInExpo = outInExpo,
    inCirc = inCirc,
    outCirc = outCirc,
    inOutCirc = inOutCirc,
    outInCirc = outInCirc,
    inElastic = inElastic,
    outElastic = outElastic,
    inOutElastic = inOutElastic,
    outInElastic = outInElastic,
    inBack = inBack,
    outBack = outBack,
    inOutBack = inOutBack,
    outInBack = outInBack,
    inBounce = inBounce,
    outBounce = outBounce,
    inOutBounce = inOutBounce,
    outInBounce = outInBounce,
  }
end
