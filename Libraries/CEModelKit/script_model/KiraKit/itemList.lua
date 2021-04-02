
-- 자세한 설명 wiki
-- https://wiki.navercorp.com/display/LFS/B612.SNOW.Contents.Bling.Kirakira.Refine


-- SINGLE은 SINGLE_ITEMS(단일 이미지)만 사용할때, ANIMATION은 ANIMATION_ITEMS(시퀀스 이미지)만 사용할 때, BOTH는 둘다 사용할 때 설정
KiraType = {
  SINGLE = 1,
  ANIMATION = 2,
  BOTH = 3
}

g_kiraType = KiraType.SINGLE


-- 키라키라 highlight 민감도, 1.0 보다 크면 클수록 키라키라 양이 많아짐, 1.0보다 작을수록(음수는 X) 키라키라양이 적어짐
-- 값 범위 : 0.0 ~ 1.5 까지 가능
g_strength = 0.7

-- KiraType.BOTH를 사용할때, 마스크의 투명한 부분에 SINGLE_ITEMS이 나타나고, 불투명한 부분에 ANIMATION_ITEMS이 나타남.
MASK_PATH = "mask.png"

-- 얼굴에 스킨 이미지를 씌워서 검은색 영역에 키라키라 효과를 제외하기 위한 flag, path 값들이다.
IS_FACE_MASKING = false
FACE_MASK_PATH = "f_mask.png"


ANIMATION_ITEMS = {
  -- 해당 파라미터 설명은 위 wiki 페이지 참조
    {fileName = "KiraKit/b_gold", minScale = 7.0, maxScale = 15.0, elementSize = math.floor(0), areaThreshold = 0.0, rotateZ = -15, scale = 1.0, fps = 24}
}

SINGLE_ITEMS = {
  -- 해당 파라미터 설명은 위 wiki 페이지 참조
    {fileName = "KiraKit/star2.png", minScale = 5.0, maxScale = 10.0, elementSize = math.floor(0), areaThreshold = 0.0, rotateZ = -15, scale = 1.0}
}
