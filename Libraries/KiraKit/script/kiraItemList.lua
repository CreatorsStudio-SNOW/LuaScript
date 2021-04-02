
          KiraType = {
            SINGLE = 1,
            ANIMATION = 2,
            BOTH = 3
          }

g_kiraType = KiraType.BOTH
g_strength = 1.2
g_postEditStrength = 1.2
IS_FACE_MASKING = true
IS_LUMINANCE_MODE = false
g_minScale = 1.8
g_maxScale = 2.4
g_elementSize = 0
g_areaThreshold = 0.0
g_rotateZ = 0.0
g_aniMinScale = 3.0
g_aniMaxScale = 3.7
g_aniElementSize = 0
g_aniAreaThreshold = 0.0
g_aniRotateZ = 0.0
g_disappearStrength = 0.15
g_fps = 24

          SINGLE_ITEMS = {
              {minScale = g_minScale, maxScale = g_maxScale, elementSize = math.floor(g_elementSize), areaThreshold = g_areaThreshold, rotateZ = g_rotateZ}
          }


          ANIMATION_ITEMS = {
             {minScale = g_aniMinScale, maxScale = g_aniMaxScale, elementSize = math.floor(g_aniElementSize), areaThreshold = g_aniAreaThreshold, rotateZ = g_aniRotateZ, fps = g_fps}
          }
