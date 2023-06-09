USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_MES_PPD]    Script Date: 2023-03-22 오전 9:17:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************************************	
	■ 프로시저	: SP_DASH_MES_PPD
	■ 작성목적	: 생산관리 / 생산실적 현황 / Tab1.일자별 Grid
	■ 실행예제	: 
				  
				  EXEC [mesuser].[SP_DASH_MES_PPD] '','','','',''
	
	■ 비    고 : 
	 

	■ 주요변경내역    
	VER        DATE			AUTHOR				DESCRIPTION
	---------  ----------	---------------		------------------------------- 
	1.0        2022-12-22	CHO Sang HO         1. 신규생성 .
	1.1        2023-02-13   CHO Sang HO         1. Update
	1.2        2023-03-20	홍승진              1. EOL_RESULT의 WORKDATE_E에 23시59분 범위확장.
*******************************************************************************************/
ALTER PROCEDURE [mesuser].[SP_DASH_MES_PPD] 
	   @WORKDATE_S			NVARCHAR(20)		-- 1.시작일
	  ,@WORKDATE_E          NVARCHAR(20)		-- 2.종료일
	  ,@WORK_ORDER          NVARCHAR(20)		-- 3.생산오더(ERP_Order)
	  ,@ITEMCODE            NVARCHAR(20)		-- 4.자재코드
AS
BEGIN
SELECT  TB.WORKDATE         -- 생산일자
	  , TB.Layer            -- 층
	  , TB.POPNO            -- POP번호
	  , TB.WORK_ORDER       -- 생산오더
	  , TB.ITEMCODE         -- 자재코드
	  , TB.ITEM             -- 자재명
	  , TB.ORDER_QUAN       -- 지시수량
	  , TB.ACCEPTANCE_QUAN  -- 양품수량
	  , TB.DEFECTIVE_QUAN   -- 불량수량
	  , TB.SUCC_RATE        -- 목표달성율
	  , TB.ERROR_rate       -- 불량율
	  , TB.WORKINGTIME      -- 가동시간
	  , TB.DOWNTIME         -- 비가동시간
	  , TB.G_UPH            -- 목표 UPH
	  , TB.P_UPH            -- 실적 UPH
	--  , TB.P_UPH/3600+'시간' + right('0'+CONVERT(varchar(2),(TB.P_UPH%3600)/ 60),2) + '분'+ right('0'+CONVERT(varchar(2),TB.P_UPH%60),2) + '초' AS P_UPH  -- 실적 UPH
	  , TB.PROCESSNAME
	  ,  Convert(numeric(13,2), Round((  Convert(numeric(13,2),TB.P_UPH)     /TB.G_UPH) * 100 ,3))  AS  PSR --생산달성율
	  , TB.Worker 
FROM(
	SELECT
          CONVERT(CHAR(10), WR.WORKDATE, 23) AS WORKDATE -- 1.생산일자           
	  , ( Select (select c_name from APP_LIBRARY_CODE where B_OID = MACHINE_LOCATION) as location 
          from MI_MACHINE where MACHINE_CODE = WR.MACHINE) AS Layer  -- 2. 층

	, (SELECT MA.PPC_NO    FROM MI_MACHINE     MA WhERE  MA.MACHINE_CODE=WR.MACHINE) AS 'POPNO'   --3.POP 번호 POP_NO
 --   , WO.WORK_ORDER_NO  AS WORK_ORDER          --4. 생산오더 WORK_ORDER
    , WO.ERP_ORDER_NO   AS WORK_ORDER           --4-1. ERP 오더번호 ERP_ORDER
	, WR.ITEMCODE       AS ITEMCODE  -- 5.자재코드 ITEMCODE
	, (SELECT  IT.ITEM_NAME  FROM  MI_ITEM   IT  WhERE  IT.ITEM_CODE=WR.ITEMCODE)   AS ITEM   --6.자재명 ITEMNAME
	, Convert(numeric(13,2),WO.ORDER_QUANTITY) AS ORDER_QUAN       --7.지시수량 ORDER_QUAN
	, Convert(numeric(13,2),WR.IN_QTY) AS ACCEPTANCE_QUAN    --8. 양품수량 ACCEPTANCE_QUAN
	, Convert(numeric(13,2),WR.BAD_QTY)  AS DEFECTIVE_QUAN    --9. 불량 수량 DEFECTIVE_QUAN
	,  Convert(numeric(13,2), Round((WR.IN_QTY/WO.ORDER_QUANTITY)*100,3)) AS SUCC_RATE   -- '10.목표달성율 = 양품수량/지시수량 *100 ' SUCC_RATE target_attainment_rate
	, Convert(numeric(13,2), Round((WR.BAD_QTY/WO.ORDER_QUANTITY)*100,3)) AS ERROR_rate   --'11.불량율 = 불량수량/ 지시수량 * 100' ERROR_rate
	, WR.WORKINGTIME AS  WORKINGTIME --'가동시간'
	--,ISNULL((select DATEDIFF(MI, DT.STARTDOWNTIME,  DT.ENDDOWNTIME)  FROM  MM_DOWNTIME DT WHERE  DT.WORKNO = WR.WORKNO),0) AS DOWNTIME -- '비가동시간(분)'
	
	, ISNULL( (SELECT  Convert(numeric(13,2), ROUND(sum(TIMESPAN),3))   FROM  [mesuser].MM_DOWNTIME DT WHERE  DT.WORKNO = WR.WORKNO GROUP BY  DT.WORKNO ),0) AS DOWNTIME -- '비가동시간(분)'
	, (SELECT  Convert(numeric(13,2), Round(IT.PRODUCTION_UPH,3))  FROM  MI_ITEM   IT  WhERE  IT.ITEM_CODE=WR.ITEMCODE)   AS G_UPH -- '목표 UPH'
	--, 
--	  CASE WHEN WorkingTime = '0' THEN 0 ELSE 
	--  (SELECT  Convert(numeric(13,2), Round((IN_QTY+BAD_QTY)/ convert(float,WorkingTime)/60,3))  FROM  MI_ITEM   IT  WhERE  IT.ITEM_CODE=WR.ITEMCODE) 
	 -- END
	  
	 -- AS P_UPH --실적UPH=생산수량(양품/불량)/가동시간'
	, 
	  CASE WHEN WorkingTime = '0' THEN 0 ELSE 
	  (SELECT  Convert(numeric(13,2), Round((IN_QTY+BAD_QTY)/
	        CASE WHEN
	               ( select count(distinct(worker_ID)) as w_CnT 
				     from [mesuser].[PP_WORKER]
                     Where  PROCESSCODE =WR.PROCESSCODE AND WORK_ORDER_NO = WR.WORKORDERNO AND MACHINE =WR.MACHINE  ) =0 THEN 1 ELSE
					 (select count(distinct(worker_ID)) as w_CnT 
				     from [mesuser].[PP_WORKER]
                     Where  PROCESSCODE =WR.PROCESSCODE AND WORK_ORDER_NO = WR.WORKORDERNO AND MACHINE =WR.MACHINE  )
			END 
                   / convert(float,WorkingTime),3))  
                     
	   FROM  [mesuser].MI_ITEM   IT  WhERE  IT.ITEM_CODE=WR.ITEMCODE) 
	  END
	  
	  AS P_UPH --실적UPH=생산수량(양품/불량)/투입인력/가동시간'
	, (select MPROCESS_NAME from [mesuser].[MI_MPROCESS] where MPROCESS_CODE=WR.PROCESSCODE) AS PROCESSNAME
	--, (SELECT  Convert(numeric(13,2), Round((IT.PRODUCTION_UPH/IT.INSPECTION_UPH) * 100 ,3)) FROM  MI_ITEM   IT  WhERE  IT.ITEM_CODE=WR.ITEMCODE)   AS PSR   --'생산 달성율'
	
	, (SELECT UR.USER_NAME  FROM  APP_User UR 
		 WHERE  UR.USER_ID IN (
		  SELECT TOP 1 WORKER_ID   FROM PP_WORKER WE
		  WHERE   WE.WORKNO=WR.WORKNO
		  order by REPEWSENT_WORKER desc
		  )) AS 'Worker'           -- 작업자  Worker
	 
FROM 
      [mesuser].PP_WORK_ORDER  WO        -- 작업지시서 
	, [mesuser].PP_WORK_RESULT WR         -- 생산실적
	
WHERE 
        WO.WORK_ORDER_NO =WR.WORKORDERNO
	   AND ( isnull(@WORKDATE_S,'')=''OR (WR.WORKDATE >= @WORKDATE_S))
       AND ( isnull(@WORKDATE_E,'')=''OR (WR.WORKDATE <= @WORKDATE_E))
	   AND ( isnull(@WORK_ORDER,'')=''OR (WO.ERP_ORDER_NO = @WORK_ORDER))
	   AND ( isnull(@ITEMCODE,'')=''OR (WR.ITEMCODE = @ITEMCODE))  
UNION

SELECT 
      CONVERT(CHAR(10), ER.WORKDATE, 23) AS WORKDATE                             -- 1.생산일자 
	, ( Select (select c_name from [mesuser].APP_LIBRARY_CODE where B_OID = MACHINE_LOCATION) as location 
          from [mesuser].MI_MACHINE where MACHINE_CODE = ER.MACHINE) AS Layer  -- 2. 층
    , (SELECT MA.PPC_NO    FROM [mesuser].MI_MACHINE     MA WhERE  MA.MACHINE_CODE=ER.MACHINE) AS 'POPNO'   --3.POP 번호 POP_NO
	, WO.ERP_ORDER_NO   AS WORK_ORDER           --4. ERP 오더번호 ERP_ORDER
	, ER.ITEMCODE       AS ITEMCODE            -- 5.자재코드 ITEMCODE
	, (SELECT  IT.ITEM_NAME  FROM  [mesuser].MI_ITEM   IT  WhERE  IT.ITEM_CODE=ER.ITEMCODE)   AS ITEM   --6.자재명 ITEMNAME
	, Convert(numeric(13,2),ER.IN_QTY+ER.BAD_QTY) AS ORDER_QUAN       --7.지시수량 ORDER_QUAN
	, Convert(numeric(13,2),ER.IN_QTY)  AS ACCEPTANCE_QUAN         --8. 양품수량 ACCEPTANCE_QUAN
	, Convert(numeric(13,2),ER.BAD_QTY) AS DEFECTIVE_QUAN          --9. 불량 수량 DEFECTIVE_QUAN
	,  Convert(numeric(13,2), Round((ER.IN_QTY/WO.ORDER_QUANTITY)*100,3)) AS SUCC_RATE   -- '10.목표달성율 = 양품수량/지시수량 *100 ' SUCC_RATE target_attainment_rate
	, Convert(numeric(13,2), Round((ER.BAD_QTY/WO.ORDER_QUANTITY)*100,3)) AS ERROR_rate   --'11.불량율 = 불량수량/ 지시수량 * 100' ERROR_rate
	, ER.WORKINGTIME AS  WORKINGTIME --'가동시간'
    , ISNULL( (SELECT  Convert(numeric(13,2), ROUND(sum(TIMESPAN),3))   FROM  [mesuser].MM_DOWNTIME DT WHERE  DT.WORKNO = ER.WORKNO GROUP BY  DT.WORKNO ),0) AS DOWNTIME -- '비가동시간(분)'
	, (SELECT  Convert(numeric(13,2), Round(IT.PRODUCTION_UPH,3))  FROM  [mesuser].MI_ITEM   IT  WhERE  IT.ITEM_CODE=ER.ITEMCODE)   AS G_UPH -- '목표 UPH'
	--, CASE WHEN WorkingTime = '0' THEN 0 ELSE 
	--  (SELECT  Convert(numeric(13,2), Round((IN_QTY+BAD_QTY)/ convert(float,WorkingTime)/60,3))  FROM  [mesuser].MI_ITEM   IT  WhERE  IT.ITEM_CODE=ER.ITEMCODE) 
	--  END
	--  AS P_UPH
   ,
	  CASE WHEN WorkingTime = '0' THEN 0 ELSE 
	   (SELECT  Convert(numeric(13,2), Round((IN_QTY+BAD_QTY)/
	        CASE WHEN
	               ( select count(distinct(worker_ID)) as w_CnT 
				     from [mesuser].[PP_WORKER]
                     Where  PROCESSCODE =ER.PROCESSCODE AND WORK_ORDER_NO = ER.WORKORDERNO AND MACHINE =ER.MACHINE  ) =0 THEN 1 ELSE
					 (select count(distinct(worker_ID)) as w_CnT 
				     from [mesuser].[PP_WORKER]
                     Where  PROCESSCODE =ER.PROCESSCODE AND WORK_ORDER_NO = ER.WORKORDERNO AND MACHINE =ER.MACHINE  )
			END 
                   / convert(float,WorkingTime),3)) * 3600 
	   FROM  [mesuser].MI_ITEM   IT  WhERE  IT.ITEM_CODE=ER.ITEMCODE) 
	  END
	  
	  AS P_UPH --실적UPH=생산수량(양품/불량)/투입인력/가동시간'

	  , (select MPROCESS_NAME from [mesuser].[MI_MPROCESS] where MPROCESS_CODE=ER.PROCESSCODE) AS PROCESSNAME
--	, (SELECT  Convert(numeric(13,2), Round((IT.PRODUCTION_UPH/IT.INSPECTION_UPH) * 100 ,3)) FROM  [mesuser].MI_ITEM   IT  WhERE  IT.ITEM_CODE=ER.ITEMCODE)   AS PSR   --'생산 달성율'
	, (SELECT UR.USER_NAME  FROM  [mesuser].APP_User UR 
		 WHERE  UR.USER_ID IN (
		  SELECT TOP 1 WORKER_ID   FROM [mesuser].PP_WORKER WE
		  WHERE   WE.WORKNO=ER.WORKNO
		  order by REPEWSENT_WORKER desc
		  )) AS 'Worker'           -- 작업자  Worker
FROM
   [mesuser].PP_WORK_ORDER  WO  
 , [mesuser].[PP_EOL_RESULT] ER
WHERE
  WO.WORK_ORDER_NO = ER.WORKORDERNO
  AND ( isnull(@WORKDATE_S,'')=''OR (ER.WORKDATE >= @WORKDATE_S))
  AND ( isnull(@WORKDATE_E,'')=''OR (ER.WORKDATE <= @WORKDATE_E + ' 23:59:59.000' ))
  AND ( isnull(@WORK_ORDER,'')=''OR (WO.ERP_ORDER_NO = @WORK_ORDER))
  AND ( isnull(@ITEMCODE,'')=''OR (ER.ITEMCODE = @ITEMCODE)) 
) AS TB
  
ORDER BY WORKDATE desc
END
