-- ��ɱִ�д洢����
DELIMITER $$
--����洢����
--������in���������  out���������
--row_count():������һ���޸�����sql��delete,insert,update����Ӱ������
CREATE PROCEDURE `seckill`.`execute_seckill`
	(in v_seckill_id bigint, in v_phone bigint,
	 in v_kill_time timestamp, out r_result int)
BEGIN
	DECLARE change_count int DEFAULT 0;
	START TRANSACTION;
	insert ignore into success_killed
	(seckill_id, user_phone, state, create_time)
	values
	(v_seckill_id, v_phone, 0, v_kill_time);
	select row_count() into change_count;
	IF (change_count = 0) THEN
		ROLLBACK;
		SET r_result = -1;
	ELSEIF (change_count < 0) THEN
		ROLLBACK;
		SET r_result = -2;
	ELSE
		UPDATE seckill
		SET number = number - 1
		WHERE seckill_id = v_seckill_id 
			AND end_time >= v_kill_time
			AND start_time <= v_kill_time
			AND number > 0;
		SELECT row_count() into change_count;
		IF (change_count = 0) THEN
			ROLLBACK;
			SET r_result = 0;
		ELSEIF (change_count < 0) THEN
			ROLLBACK;
			set r_result = -2;
		ELSE
			COMMIT;
			SET r_result = 1;
		END IF;
	END IF;
END;
$$
--�洢���̶������

DELIMITER ;

set @r_result=-3;
--ִ�д洢����
call execute_seckill(1003,18817573572,now(),@r_result);
--��ȡ���
select @r_result;