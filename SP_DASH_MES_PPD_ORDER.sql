USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_MES_PPD_ORDER]    Script Date: 2023-03-22 오전 9:26:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************************************	
	■ 프로시저	: SP_DASH_MES_PPD_ORDER
	■ 작성목적	: 생산실적현황 / tab2.오더별의 Grid
	■ 실행예제	: 
				  
				  EXEC mesuser.SP_DASH_MES_PPD_ORDER '','', '',''
	
	■ 비    고 : 
	 

	■ 주요변경내역    
	VER        DATE			AUTHOR				DESCRIPTION
	---------  ----------	---------------		------------------------------- 
	1.0        2023-01-11	CHO Sang HO         1. 신규생성 
	1.1        2023-03-14   홍승진	     	    1. EOL 검사 여부 검증 수정
	1.2        2023-03-15   홍승진	     	    1. 외관검사, 출하검사에 CASE문 추가
									     	    2. 주석 명칭 수정.
	1.3        2023-03-16   홍승진	     	    1. 목표달성율 컬럼 계산식 변경.
	1.4		   2023-03-20	고광남              1. ERP_ORDER_NO 순으로 Group By.
	1.5        2023-03-20   홍승진              1. 생산달성율 수정
*******************************************************************************************/
ALTER PROCEDURE [mesuser].[SP_DASH_MES_PPD_ORDER] 
	   @WORKDATE_S			NVARCHAR(20)		-- 시작일
	  ,@WORKDATE_E          NVARCHAR(20)		-- 종료일
	  ,@WORK_ORDER          NVARCHAR(20)		-- 생산오더
	  ,@ITEMCODE            NVARCHAR(20)		-- 자재코드
AS
BEGIN

	SET NOCOUNT ON;
	SET ANSI_WARNINGS OFF
	SET ARITHIGNORE ON
	SET ARITHABORT OFF
	
	SELECT ERP_ORDER_NO               -- 1.ERP Order
	     , ITEMCODE                    -- 2.자재코드	
	     , ITEM  
	     , P001_IORDER_QUANTITY
	     , P001_IN_QTY
	     , P001_BAD_QTY
		 , ISNULL(Convert(NUMERIC(6,2),(P001_IN_QTY / P001_IORDER_QUANTITY) * 100),0) As  P001_SUCESS_P
		 , ISNULL(Convert(NUMERIC(6,2),(P001_BAD_QTY / P001_IORDER_QUANTITY) * 100),0) As P001_Fail_P
		 , P001_G_UPH
	     , P002_IORDER_QUANTITY
	     , P002_IN_QTY
	     , P002_BAD_QTY
	     , ISNULL(Convert(NUMERIC(6,2),(P002_IN_QTY / P002_IORDER_QUANTITY) * 100),0) As  P002_SUCESS_P
	     , ISNULL(Convert(NUMERIC(6,2),(P002_BAD_QTY / P002_IORDER_QUANTITY) * 100),0) As P002_Fail_P
		 , P002_G_UPH
		 , FQC_INS_QTY
	     , FQC_FAIR_QTY
	     , FQC_DEF_QTY
	     , ISNULL(Convert(NUMERIC(6,2),(FQC_FAIR_QTY / FQC_INS_QTY) * 100),0) As FQC_SUCESS_P
	     , ISNULL(Convert(NUMERIC(6,2),(FQC_DEF_QTY / FQC_INS_QTY) * 100),0) As FQC_Fail_P
		 , FQC_G_UPH
		 , OQC_INPEC_QTY
	     , OQC_FAIR__QTY
	     , OQC_DEF_QTY
	     , ISNULL(Convert(NUMERIC(6,2),(OQC_FAIR__QTY / OQC_INPEC_QTY) * 100),0) As OQC_SUCESS_P
	     , ISNULL(Convert(NUMERIC(6,2),(OQC_DEF_QTY / OQC_INPEC_QTY) * 100),0) As OQC_Fail_P
		 , OQC_G_UPH
	FROM
    (SELECT T.ERP_ORDER_NO               -- 1.ERP Order
	      , T.ITEMCODE                    -- 2.자재코드	
	      , T.ITEM                        -- 3.자재명
	   ---------------------- P001 :: 생산 (구:조립) ----------------------
	      , SUM(CASE WHEN MPR.MPROCESS_CODE = 'P001' THEN T.P001_IORDER_QUANTITY ELSE 0 END) As P001_IORDER_QUANTITY
	      , SUM(CASE WHEN MPR.MPROCESS_CODE = 'P001' THEN T.P001_IN_QTY ELSE 0 END) As P001_IN_QTY
	      , SUM(CASE WHEN MPR.MPROCESS_CODE = 'P001' THEN T.P001_BAD_QTY ELSE 0 END) As P001_BAD_QTY
		  --, SUM(CASE WHEN MPR.MPROCESS_CODE = 'P001' THEN T.P001_SUCESS_P ELSE 0 END) As P001_SUCESS_P
	   --   , SUM(CASE WHEN MPR.MPROCESS_CODE = 'P001' THEN T.P001_Fail_P ELSE 0 END) As P001_Fail_P
		  , SUM(CASE WHEN MPR.MPROCESS_CODE = 'P001' THEN T.P001_G_UPH ELSE 0 END) As P001_G_UPH
	   ---------------------- P002 :: EOL ----------------------
	      , SUM(CASE WHEN MPR.MPROCESS_CODE = 'P002' THEN T.P002_IORDER_QUANTITY ELSE 0 END) As P002_IORDER_QUANTITY
	      , SUM(CASE WHEN MPR.MPROCESS_CODE = 'P002' THEN T.P002_IN_QTY ELSE 0 END) As P002_IN_QTY
	      , SUM(CASE WHEN MPR.MPROCESS_CODE = 'P002' THEN T.P002_BAD_QTY ELSE 0 END) As P002_BAD_QTY
	      --, SUM(CASE WHEN MPR.MPROCESS_CODE = 'P002' THEN T.P002_SUCESS_P ELSE 0 END) As P002_SUCESS_P
	      --, SUM(CASE WHEN MPR.MPROCESS_CODE = 'P002' THEN T.P002_Fail_P ELSE 0 END) As P002_Fail_P
		  , SUM(CASE WHEN MPR.MPROCESS_CODE = 'P002' THEN T.P002_G_UPH ELSE 0 END) As P002_G_UPH
--	   ---------------------- P003 :: 외관검사 (구:최종검사) ----------------------
	      , SUM(CASE WHEN MPR.MPROCESS_CODE = 'P003' THEN T.FQC_INS_QTY ELSE 0 END) As FQC_INS_QTY
	      , SUM(CASE WHEN MPR.MPROCESS_CODE = 'P003' THEN T.FQC_FAIR_QTY ELSE 0 END) As FQC_FAIR_QTY
	      , SUM(CASE WHEN MPR.MPROCESS_CODE = 'P003' THEN T.FQC_DEF_QTY ELSE 0 END) As FQC_DEF_QTY
	      --, SUM(CASE WHEN MPR.MPROCESS_CODE = 'P003' THEN T.FQC_SUCESS_P ELSE 0 END) As FQC_SUCESS_P
	      --, SUM(CASE WHEN MPR.MPROCESS_CODE = 'P003' THEN T.FQC_Fail_P ELSE 0 END) As FQC_Fail_P
		  , SUM(CASE WHEN MPR.MPROCESS_CODE = 'P003' THEN T.FQC_G_UPH ELSE 0 END) As FQC_G_UPH
--	   ---------------------- P004 :: 출하검사 ----------------------		 
          , SUM(CASE WHEN MPR.MPROCESS_CODE = 'P004' THEN T.OQC_INPEC_QTY ELSE 0 END) As OQC_INPEC_QTY
	      , SUM(CASE WHEN MPR.MPROCESS_CODE = 'P004' THEN T.OQC_FAIR__QTY ELSE 0 END) As OQC_FAIR__QTY
	      , SUM(CASE WHEN MPR.MPROCESS_CODE = 'P004' THEN T.OQC_DEF_QTY ELSE 0 END) As OQC_DEF_QTY
	      --, SUM(CASE WHEN MPR.MPROCESS_CODE = 'P004' THEN T.OQC_SUCESS_P ELSE 0 END) As OQC_SUCESS_P
	      --, SUM(CASE WHEN MPR.MPROCESS_CODE = 'P004' THEN T.OQC_Fail_P ELSE 0 END) As OQC_Fail_P
		  , SUM(CASE WHEN MPR.MPROCESS_CODE = 'P004' THEN T.OQC_G_UPH ELSE 0 END) As OQC_G_UPH
	 FROM 
     (SELECT ERP_ORDER_NO                -- 1.ERP Order
           , ITEMCODE                    -- 2.자재코드	
	       , ITEM                        -- 3.자재명
	  ---------------------- P001  생산 (구:조립)  ----------------------
	       , Convert(NUMERIC(6,2), P001_IORDER_QUANTITY) AS  P001_IORDER_QUANTITY         -- 4.조립 지시수량   
	       , Convert(NUMERIC(6,2), P001_IN_QTY)          AS   P001_IN_QTY                 -- 5.조립 양품수량
	       , Convert(NUMERIC(6,2), P001_BAD_QTY)         AS P001_BAD_QTY                  -- 6.조립 불량수량
	       , Convert(NUMERIC(6,2), P001_SUCESS_P)        AS P001_SUCESS_P                 -- 7.조립 목표달성율
	       , Convert(NUMERIC(6,2), P001_Fail_P)          AS P001_Fail_P                   -- 8.조립 불량율	  
	       , CASE WHEN DIFF_MIN =0 THEN 100 
		          ELSE ISnull((SELECT  Convert(numeric(13,3), Round((IT.PRODUCTION_UPH/P_UPH_P001/DIFF_MIN/60) * 100 ,4)) --9.부분 생산시간
			                   FROM  [mesuser].MI_ITEM   IT  WhERE  IT.ITEM_CODE=ITEMCODE)  ,0) End  AS P001_G_UPH   -- 9.'생산 달성율'
	  ------------------ P002 :: EOL ----------------------
	      , Convert(NUMERIC(6,2), P002_IORDER_QUANTITY)   AS P002_IORDER_QUANTITY            --10.EOL 지시수량
	      , Convert(NUMERIC(6,2), P002_IN_QTY)            AS P002_IN_QTY                     --11.EOL 양품수량
	      , Convert(NUMERIC(6,2), P002_BAD_QTY)           AS P002_BAD_QTY                    --12.EOL 불량수량
	      , Convert(NUMERIC(6,2), P002_SUCESS_P)          AS P002_SUCESS_P                   --13.EOL 목표달성율
	      , Convert(NUMERIC(6,2), P002_Fail_P)            AS P002_Fail_P                      --14.EOL 불량율
	      , ISNULL(Convert(NUMERIC(6,2),(P002_IN_QTY / P002_IORDER_QUANTITY) * 100),0) As P002_SUCESS_P_EOL
	      , ISNULL(Convert(NUMERIC(6,2),(P002_BAD_QTY / P002_IORDER_QUANTITY) * 100),0) As P002_Fail_P_EOL
	      , ISnull((SELECT  Convert(numeric(13,3), Round((IT.INSPECTION_UPH/P_UPH_P002/DIFF_MIN_EOL/60) * 100 ,4)) 
		            FROM  [mesuser].MI_ITEM   IT  WhERE  IT.ITEM_CODE=ITEMCODE),0)   AS P002_G_UPH   -- 15.생산 달성율
       ----------------  P003 :: 외관검사 (구:최종검사)  ----------------------
	      , Convert(NUMERIC(6,2), FQC_INS_QTY)             AS FQC_INS_QTY                      --16.외관검사 지시수량
	      , Convert(NUMERIC(6,2), FQC_FAIR_QTY)            AS FQC_FAIR_QTY                     --17.외관검사 양품수량
	      , Convert(NUMERIC(6,2), FQC_DEF_QTY)             AS  FQC_DEF_QTY                     --18.외관검사 불량수량	
	      , Convert(NUMERIC(6,2), FQC_SUCESS_P)            AS FQC_SUCESS_P                     --19.외관검사 목표달성율
	      , Convert(NUMERIC(6,2), FQC_Fail_P)              AS FQC_Fail_P                        --20.외관검사 불량율
	      , ISNULL(Convert(NUMERIC(6,2),(FQC_FAIR_QTY / FQC_INS_QTY) * 100),0) As FQC_SUCESS_P_EOL
	      , ISNULL(Convert(NUMERIC(6,2),(FQC_DEF_QTY / FQC_INS_QTY) * 100),0) As FQC_Fail_P_EOL
	      , ISNULL(  (SELECT  Convert(numeric(6,2), Round((IT.INSPECTION_UPH/P_UPH_FQC/DIFF_MIN_FQC/60) * 100 ,4)) 
			          FROM  [mesuser].MI_ITEM   IT  WhERE  IT.ITEM_CODE=ITEMCODE),0)   AS FQC_G_UPH   -- 21.생산 달성율
	  -------------- P004 :: 출하검사  ----------------------
	      , Convert(NUMERIC(6,2), OQC_INPEC_QTY)           AS OQC_INPEC_QTY                      -- 22.출하검사 지시수량
	      , Convert(NUMERIC(6,2), OQC_FAIR__QTY)           AS OQC_FAIR__QTY                      -- 23.출하검사 양품수
	      , Convert(NUMERIC(6,2), OQC_DEF_QTY)             AS OQC_DEF_QTY                        -- 24.출하검사 불량수 
	      , Convert(NUMERIC(6,2), OQC_SUCESS_P)            AS OQC_SUCESS_P                       -- 25.출하검사 목표달성율
	      , Convert(NUMERIC(6,2), OQC_Fail_P)              AS OQC_Fail_P                         -- 26.출하검사 불량율
	      , ISNULL(Convert(NUMERIC(6,2),(OQC_FAIR__QTY / OQC_INPEC_QTY) * 100),0) As OQC_SUCESS_P_EOL
	      , ISNULL(Convert(NUMERIC(6,2),(OQC_DEF_QTY / OQC_INPEC_QTY) * 100),0) As OQC_Fail_P_EOL
	      , isnull(  (SELECT  Convert(numeric(13,3), Round((IT.INSPECTION_UPH/P_UPH_OQC/DIFF_MIN_OQC/60) * 100 ,4)) 
			          FROM  [mesuser].MI_ITEM   IT  WhERE  IT.ITEM_CODE=ITEMCODE),0)   AS OQC_G_UPH   -- 27.생산 달성율
  FROM 
  (SELECT WR1.ERP_ORDER_NO  AS ERP_ORDER_NO                     --   1.ERP Order
	    , WR1.[ITEMCODE]    AS ITEMCODE                         -- 2.자재코드	
	    , (SELECT  IT.ITEM_NAME  FROM  [mesuser].MI_ITEM   IT
	       WhERE  IT.ITEM_CODE=WR1.[ITEMCODE] )   AS ITEM   --3.자재명
	 ------------ P001 조립 ----------------------
	    , WR1.PROCESSCODE AS PROCESS1
	    , ISNULL(WO.ORDER_QUANTITY,0)  AS P001_IORDER_QUANTITY   -- 1. 지시수량
	    , ISNULL(WR1.IN_QTY,0)   AS P001_IN_QTY  -- 2. 양품수량
	    , ISNULL(WR1.BAD_QTY,0)   AS P001_BAD_QTY  -- 3. 불량수량
	    , Round( convert(float,ISNULL(WR1.IN_QTY  / (WR1.IN_QTY +WR1.BAD_QTY) *100,0)),2) AS P001_SUCESS_P -- 4. 목표달성율 =양품수량/지시수량*100
	    , Round( convert(float,ISNULL(WR1.BAD_QTY / (WR1.IN_QTY+WR1.BAD_QTY)*100,0)),2)  AS P001_Fail_P   --5.불량율
        , convert(float,WR1.WORKINGTIME) *60 AS DIFF_MIN
	    , CASE WHEN WR1.WorkingTime = '0' THEN 0 
		       ELSE  (SELECT  Convert(numeric(13,2), Round((WR1.IN_QTY+WR1.BAD_QTY)/
						CASE WHEN ( select count(distinct(worker_ID)) as w_CnT 
				                    from [mesuser].[PP_WORKER]
                                    Where  PROCESSCODE =WR1.PROCESSCODE AND WORKORDERNO = WR1.WORKORDERNO AND MACHINE =WR1.MACHINE  ) =0 THEN 1 
							 ELSE (select count(distinct(worker_ID)) as w_CnT 
				                   from [mesuser].[PP_WORKER]
                                   Where  PROCESSCODE =WR1.PROCESSCODE AND WORKORDERNO = WR1.WORKORDERNO AND MACHINE =WR1.MACHINE  )
			                 END 
                                 / convert(float,WR1.WorkingTime),3))  
	                 FROM  [mesuser].MI_ITEM   IT  WhERE  IT.ITEM_CODE=WR1.ITEMCODE) 
	      END  AS P_UPH_P001 --실적UPH=생산수량(양품/불량)/투입인력/가동시간'

	 ---------- P002 EOL검사 --------------------
	    , WR2.PROCESSCODE AS PROCESS2
	    , ISNULL(WR1.IN_QTY,0)  AS P002_IORDER_QUANTITY   -- 1. 지시수량 = P001 양품수량
	    , ISNULL(WR2.IN_QTY,0)  AS P002_IN_QTY            -- 2. 양품수량
	    , ISNULL(WR2.BAD_QTY,0) AS P002_BAD_QTY           -- 3. 불량수량	       
        , Round( convert(float,ISNULL(WR2.IN_QTY  / WR1.IN_QTY * 100,0)),2)  AS P002_SUCESS_P -- 4.목표달성율 = 양품수량/지시수량  *100
	    , Round( convert(float,ISNULL(WR2.BAD_QTY / WR1.IN_QTY * 100,0)),2)  AS P002_Fail_P   --5.불량율 = 불량수량/지시수량  *100
	    , convert(float,WR2.WORKINGTIME) *60 AS DIFF_MIN_EOL
	    , CASE WHEN WR2.WorkingTime = '0' THEN 0 ELSE 
	  (SELECT  Convert(numeric(13,2), Round((WR2.IN_QTY+WR1.BAD_QTY)/
	        CASE WHEN
	               ( select count(distinct(worker_ID)) as w_CnT 
				     from [mesuser].[PP_WORKER]
                     Where  PROCESSCODE =WR1.PROCESSCODE AND WORKORDERNO = WR2.WORKORDERNO AND MACHINE =WR2.MACHINE  ) =0 THEN 1 ELSE
					 (select count(distinct(worker_ID)) as w_CnT 
				     from [mesuser].[PP_WORKER]
                     Where  PROCESSCODE =WR1.PROCESSCODE AND WORKORDERNO = WR2.WORKORDERNO AND MACHINE =WR2.MACHINE  )
			END 
                   / convert(float,WR2.WorkingTime),3))  
                     
	   FROM  [mesuser].MI_ITEM   IT  WhERE  IT.ITEM_CODE=WR2.ITEMCODE) 
	  END	  
	  AS P_UPH_P002 --실적UPH=생산수량(양품/불량)/투입인력/가동시간'

	   	 -------최종검사
      , ISNULL(WR2.IN_QTY,ISNULL(WR1.IN_QTY,0)) AS   FQC_INS_QTY -- FQC_INS_QTY -- 1. 최종검사 지시수량
	  , ISNULL(FQC.FAIR_QUALITY_QTY,0) AS FQC_FAIR_QTY -- 2.양품수량
      , ISNULL(FQC.DEFECT_QUALITY_QTY,0) AS FQC_DEF_QTY -- 3.불량수

	  , CASE WHEN FQC.TOTAL_QTY IS NULL THEN 0 ELSE
	        CASE WHEN  FQC.TOTAL_QTY = 0 THEN 0 ELSE
	        ISNULL(Round(convert(float,FQC.FAIR_QUALITY_QTY)/ convert(float, FQC.TOTAL_QTY),4)*100,0)
		   END
		END 
		AS FQC_SUCESS_P  --4. 최종검사 목표달성율
	  , CASE WHEN FQC.FAIR_QUALITY_QTY IS NULL THEN 0 ELSE
	        CASE WHEN (FQC.FAIR_QUALITY_QTY+FQC.DEFECT_QUALITY_QTY) = 0 THEN 0 ELSE
	         Round(convert(float,ISNULL(FQC.DEFECT_QUALITY_QTY,0)/
	        convert(float, ISNULL(FQC.FAIR_QUALITY_QTY+FQC.DEFECT_QUALITY_QTY,0) )),4)*100 
	        END
		END AS FQC_Fail_P   --5.불량율
	, DATEDIFF(MI, FQC.INSP_START_DATE  ,  FQC.INSP_END_DATE) AS DIFF_MIN_FQC
	, CASE WHEN FQC.INSP_WORKING_TIME = '0' THEN 0 ELSE 
	  (SELECT  Convert(numeric(13,2), Round((WR2.IN_QTY+WR1.BAD_QTY)/
	        CASE WHEN
	               ( select count(distinct(worker_ID)) as w_CnT 
				     from [mesuser].[PP_WORKER]
                     Where   WORKORDERNO = FQC.WORK_ORDER_NO AND MACHINE =WR1.MACHINE  ) =0 THEN 1 ELSE
					 (select count(distinct(worker_ID)) as w_CnT 
				     from [mesuser].[PP_WORKER]
                     Where  WORKORDERNO = FQC.WORK_ORDER_NO AND MACHINE =WR1.MACHINE  )
			END 
                   / convert(float,FQC.INSP_START_DATE),3))  
                     
	   FROM  [mesuser].MI_ITEM   IT  WhERE  IT.ITEM_CODE=WR1.ITEMCODE) 
	  END	  
	  AS P_UPH_FQC --실적UPH=생산수량(양품/불량)/투입인력/가동시간'
	  --------- 출하검사
	  , ISNULL(FQC.FAIR_QUALITY_QTY,0) as OQC_INPEC_QTY --1.출하검사 지시수량
	  , ISNULL(OQC.[FAIR_QUALITY_QTY],0) as OQC_FAIR__QTY --2. 양품수
 	  , ISNULL(OQC.DEFECT_QUALITY_QTY,0) as OQC_DEF_QTY --3.불량수
	  , CASE WHEN OQC.TOTAL_QTY  IS NULL THEN 0 ELSE
	         CASE WHEN OQC.TOTAL_QTY = 0 THEN 0 ELSE	  
	    ISNULL(Round(convert(float,OQC.FAIR_QUALITY_QTY)/ convert(float, OQC.TOTAL_QTY),4)*100,0)
	    	END 
		END
		AS OQC_SUCESS_P  --4. 최종검사 목표달성율
	  , CASE WHEN OQC.FAIR_QUALITY_QTY IS NULL THEN 0 ELSE
	      CASE WHEN  (OQC.FAIR_QUALITY_QTY+OQC.DEFECT_QUALITY_QTY) = 0 THEN 0 ELSE
	          Round(convert(float,ISNULL(OQC.DEFECT_QUALITY_QTY,0)/
	          convert(float, ISNULL(OQC.FAIR_QUALITY_QTY+OQC.DEFECT_QUALITY_QTY,0) )),4)*100
	      END   
	  END AS OQC_Fail_P   --5.불량율
	  , DATEDIFF(MI, OQC.INSP_START_DATE  ,  OQC.INSP_END_DATE) AS DIFF_MIN_OQC
	  , 
	  CASE WHEN OQC.INSP_WORKING_TIME = '0' THEN 0 ELSE 
	  (SELECT  Convert(numeric(13,2), Round((WR2.IN_QTY+WR1.BAD_QTY)/
	        CASE WHEN
	               ( select count(distinct(worker_ID)) as w_CnT 
				     from [mesuser].[PP_WORKER]
                     Where   WORKORDERNO = OQC.WORK_ORDER_NO AND MACHINE =WR1.MACHINE  ) =0 THEN 1 ELSE
					 (select count(distinct(worker_ID)) as w_CnT 
				     from [mesuser].[PP_WORKER]
                     Where  WORKORDERNO = OQC.WORK_ORDER_NO AND MACHINE =WR1.MACHINE  )
			END 
                   / convert(float,OQC.INSP_START_DATE),3))  
                     
	   FROM  [mesuser].MI_ITEM   IT  WhERE  IT.ITEM_CODE=WR1.ITEMCODE) 
	  END	  
	  AS P_UPH_OQC --실적UPH=생산수량(양품/불량)/투입인력/가동시간'

FROM [mesuser].PP_WORK_ORDER  WO
    ,  dbo.VW_WORK_Result_P001 WR1
Left JOIN  [ExPle_DEV].[mesuser].[PP_EOL_RESULT] WR2            --EOL 검사
    ON WR1.ERP_ORDER_NO = WR2.ERP_ORDER_NO
Left JOIN   [mesuser].[QM_FQC_MASTER]  FQC  --촤종검사
	ON WR1.ERP_ORDER_NO = FQC.ERP_ORDER_NO
Left JOIN   [mesuser].QM_OQC_MASTER  OQC   -- 출하검사
	ON WR1.ERP_ORDER_NO = OQC.ERP_ORDER_NO
Where 1=1
      AND WO.WORK_ORDER_NO =WR1.WORKORDERNO
      AND ( isnull(@WORKDATE_S,'')=''OR (WR1.WORKDATE >= @WORKDATE_S))
      AND ( isnull(@WORKDATE_E,'')=''OR (WR1.WORKDATE <= @WORKDATE_E))
	  AND ( isnull(@WORK_ORDER,'')=''OR (WR1.ERP_ORDER_NO = @WORK_ORDER))
	  AND ( isnull(@ITEMCODE,'')=''OR (WR1.ITEMCODE = @ITEMCODE))
) AS TS) As T
LEFT JOIN 
mesuser.MI_ROUTING_ITEM As RIT
	ON RIT.ITEM_CODE = T.ITEMCODE
LEFT JOIN 
mesuser.MI_MPROCESS As MPR
	ON MPR.MPROCESS_CODE = RIT.MPROCESS_CODE
GROUP BY T.ERP_ORDER_NO               -- 1.ERP Order
	   ,   T.ITEMCODE                    -- 2.자재코드	
	   ,   T.ITEM                        -- 3.자재명 
	--   , MPR.MPROCESS_CODE
) As Y
END