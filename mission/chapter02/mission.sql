-- 내가 진행중, 진행 완료한 미션 모아서 보는 쿼리(페이징 포함)
SELECT mission.id, store.name, mission.reward, mission.spec, member_mission.status 
FROM member 
JOIN member_mission ON member.id = member_mission.member_id 
JOIN mission ON mission.id = member_mission.mission_id 
JOIN store ON mission.store_id = store.id 
WHERE member.id = :memberId
AND member_mission.status = '진행중' /* or '진행완료' */
  AND (:cursorId IS NULL OR mission.id < :cursorId) 
ORDER BY mission.id DESC
LIMIT :limit; 


-- 리뷰 작성하는 쿼리 (사진의 경우는 일단 배제)
INSERT INTO review (
	 member_id,
	 store_id,
	 body,
   score,
	 created_at,
	 updated_at
) VALUES (
	 :memberId,
	 :storeId,
	 :body,
	 :score,
	 NOW(),
	 NOW()
);


-- 홈 화면 쿼리 (현재 선택 된 지역에서 도전이 가능한 미션 목록, 페이징 포함)
SELECT 
    m.id,
    s.name,
    m.reward,
    m.dead_line,
    m.spec,
    u.completed_missions   // 유저 성공미션 수
FROM mission m
JOIN store s ON m.store_id = s.id
JOIN region r ON s.region_id = r.id
CROSS JOIN (
    SELECT COUNT(*) AS completed_missions
    FROM member_mission mm
    WHERE mm.member_id = :memberId
      AND mm.status = 'COMPLETED'
) u
WHERE r.name = :name
  AND m.dead_line >= NOW()
  AND (:cursor IS NULL OR m.id > :cursor)
ORDER BY m.id ASC
LIMIT :limit;


-- 마이페이지 화면쿼리
SELECT name, email, phone_num, point
FROM member
WHERE id = :memberID ;