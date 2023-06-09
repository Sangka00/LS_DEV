USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_MES_NON_OPER]    Script Date: 2023-03-22 오전 9:13:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,CHO, Sang HO>
-- Create date: <2023-03-17,,>
-- Description:	<품질관리_비가동이력,,>
-- =============================================
/*******************************************************************************************	
	■ 프로시저	: SP_DASH_MES_NON_OPER
	■ 작성목적	: 품질관리 > 검사현황(구:비가동이력(품질)) / Tab1. 비가동이력
	■ 실행예제	: 
				  
				  EXEC [mesuser].[SP_DASH_MES_NON_OPER] '','','',''
	
	■ 비    고 : 
	 

	■ 주요변경내역    
	VER        DATE			AUTHOR				DESCRIPTION
	---------  ----------	---------------		------------------------------- 
	1.0        2023-03-17	CHO Sang HO         1. 신규생성 .
	1.1		   2023-03-21   홍승진				1. 주석 추가
*******************************************************************************************/
ALTER PROCEDURE [mesuser].[SP_DASH_MES_NON_OPER] 
	     @WORKDATE_S			NVARCHAR(20)    -- 시작일
		,@WORKDATE_E            NVARCHAR(20)	-- 종료일
		,@ITEM_CODE             NVARCHAR(20)    -- 자재코드
	    ,@ERP_ORDER_NO          NVARCHAR(20)    -- ERP_ORDER_NO
		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   SELECT 
        WORKDATE		  -- 1.검사일자
      , Layer             -- 2.위치정보
	  , POPNO             -- 3.POP NO 
	  , BATCH             -- 4.BATCH 
	  , TEST_PROCESS_TYPE -- 5.검사유형
	  , ERP_ORDER_NO      -- 6.오더번호
	  , ITEM_CODE         -- 7.자재코드
	  , ITEM_NAME         -- 8.자재명
	  , STARTDOWNTIME     -- 9.시작일자
	  , ENDDOWNTIME       -- 10.종료일자
	  , INSP_WORKING_TIME -- 중지시간
	  , Reason		      -- 비가동 사유
FROM(
	SELECT 
	  CONVERT(CHAR(10), QM.TEST_DATE, 23) AS WORKDATE                                         -- 1.검사일자	    
	  , (select top 1 C_NAME from [dbo].[VW_Layers] Where popno = DT.POPNO ) AS Layer         -- 2.위치정보
	 , DT.POPNO             AS POPNO                                                          -- 3.POP NO 
	 , DT.BATCH             AS BATCH                                                          -- 4.BATCH  
	 , '출하검사'           AS TEST_PROCESS_TYPE                                              -- 5.검사유형
	 , QM.ERP_ORDER_NO      AS ERP_ORDER_NO                                                   -- 6.오더번호
	-- , QM.WORK_ORDER_NO															          
	 , QM.ITEM_CODE         AS ITEM_CODE                                                      -- 7.자재코드
	 , QM.ITEM_NAME         AS ITEM_NAME                                                      -- 8.자재명 
	 , CONVERT(CHAR(10), DT.STARTDOWNTIME , 23)    AS STARTDOWNTIME                           -- 9.시작일자
     , CONVERT(CHAR(10), DT.ENDDOWNTIME  , 23)       AS ENDDOWNTIME                           -- 10.종료일자
	 , Convert(numeric(13,3), Convert(numeric(13,3),TIMESPAN*60) / 60) AS INSP_WORKING_TIME

     , ( SELECT APP.C_NAME  FROM APP_LIBRARY_CODE APP Where APP.C_CODE =DT.DOWNTIMECODE) AS Reason --'비가동 사유'		
	FROM 
	    [QM_OQC_MASTER] QM,[MM_QC_DOWNTIME] DT
	WHERE QM.ITEM_CODE = DT.ITEMCODE
	      AND QM.POP_NO =DT.POPNO
		  AND QM.INSP_BATCH_NO = DT.BATCH
UNION
SELECT 
	  CONVERT(CHAR(10), FQC.TEST_DATE, 23) AS WORKDATE                                  -- 1.검사일자	    
	  , (select top 1 C_NAME from [dbo].[VW_Layers] Where popno = DT.POPNO ) AS Layer   -- 2.위치정보
	 , DT.POPNO             AS POPNO                                                    -- 3.POP NO 
	 , DT.BATCH             AS BATCH                                                    -- 4.BATCH  
	 , '최종검사'           AS TEST_PROCESS_TYPE                                        -- 5.검사유형
	 , FQC.ERP_ORDER_NO      AS ERP_ORDER_NO                                            -- 6.오더번호
	-- , QM.WORK_ORDER_NO
	 , FQC.ITEM_CODE         AS ITEM_CODE                                               --7.자재코드
	 , FQC.ITEM_NAME         AS ITEM_NAME                                               --8.자재명 
	 ,  CONVERT(CHAR(10), DT.STARTDOWNTIME , 23)     AS STARTDOWNTIME                                          --9.시작일자
     ,  CONVERT(CHAR(10), DT.ENDDOWNTIME  , 23)      AS ENDDOWNTIME                                            --10.종료일자
	 , Convert(numeric(13,3), Convert(numeric(13,3),TIMESPAN*60) / 60) AS INSP_WORKING_TIME

     , ( SELECT APP.C_NAME  FROM APP_LIBRARY_CODE APP Where APP.C_CODE =DT.DOWNTIMECODE) AS Reason --'비가동 사유'		
	FROM 
	     [QM_FQC_MASTER] FQC, [MM_QC_DOWNTIME] DT
	WHERE FQC.ITEM_CODE = DT.ITEMCODE
	      AND FQC.POP_NO =DT.POPNO
		  AND FQC.INSP_BATCH_NO = DT.BATCH
UNION
SELECT 
	  CONVERT(CHAR(10), IQC.TEST_DATE, 23) AS WORKDATE                                  -- 1.검사일자	    
	  , (select top 1 C_NAME from [dbo].[VW_Layers] Where popno = DT.POPNO ) AS Layer  -- 2.위치정보
	 , DT.POPNO             AS POPNO                                                   -- 3.POP NO 
	 , DT.BATCH             AS BATCH                                                   -- 4.BATCH  
	 , '수입검사'           AS TEST_PROCESS_TYPE                                       -- 5.검사유형
	-- , IQC.ERP_ORDER_NO      AS ERP_ORDER_NO                                            -- 6.오더번호
	 ,  '' AS ERP_ORDER_NO 
	 , IQC.ITEM_CODE         AS ITEM_CODE                                               --7.자재코드
	 , IQC.ITEM_NAME         AS ITEM_NAME                                               --8.자재명 
	 ,  CONVERT(CHAR(10), DT.STARTDOWNTIME , 23)    AS STARTDOWNTIME                                           --9.시작일자
     ,  CONVERT(CHAR(10), DT.ENDDOWNTIME  , 23)      AS ENDDOWNTIME                                            --10.종료일자
	 , Convert(numeric(13,3), Convert(numeric(13,3),TIMESPAN*60) / 60) AS INSP_WORKING_TIME

     , ( SELECT APP.C_NAME  FROM APP_LIBRARY_CODE APP Where APP.C_CODE =DT.DOWNTIMECODE) AS Reason --'비가동 사유'		
	FROM 
	     [QM_IQC_MASTER] IQC,[MM_QC_DOWNTIME] DT
	WHERE IQC.ITEM_CODE = DT.ITEMCODE
	      AND IQC.POP_NO =DT.POPNO
		  AND IQC.INSP_BATCH_NO = DT.BATCH
		  ) AS O

Where 1=1
    AND ( isnull(@WORKDATE_S,'')='' OR (WORKDATE >= @WORKDATE_S))
    AND ( isnull(@WORKDATE_E,'')='' OR (WORKDATE <= @WORKDATE_E))
    AND ( isnull(@ITEM_CODE,'')=''  OR  (ITEM_CODE =@ITEM_CODE))
	AND ( isnull(@ERP_ORDER_NO,'')='' OR  (ERP_ORDER_NO =@ERP_ORDER_NO))
	
	ORDER BY  WORKDATE
END
