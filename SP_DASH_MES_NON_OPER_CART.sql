﻿USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_NON_OPER_PERCENT]    Script Date: 2023-03-22 오전 9:29:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================

-- Create date: <2023-03-20,,>
-- Description:	<검사현황,비가동율,>

/*******************************************************************************************	
	■ 프로시저	: SP_DASH_MES_NON_OPER_CART
	■ 작성목적	: 품질관리 / 비가동현황(품질) / Tab2. 비가동률
	
*******************************************************************************************/
ALTER PROCEDURE [mesuser].[SP_DASH_NON_OPER_PERCENT]
	   @WORKDATE_S			NVARCHAR(20)		-- 1.시작일
	  ,@WORKDATE_E          NVARCHAR(20)		-- 2.종료일	
	  ,@Layer               NVARCHAR(20)		-- 3.층수
	  ,@POPNO               NVARCHAR(20)		-- 4.POPNO
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET ANSI_WARNINGS OFF
    SET ARITHIGNORE ON
    SET ARITHABORT OFF
	SET NOCOUNT ON;

SELECT 
          POP_NO                            -- 1.POP번호
		, Max(Layer) as  Layer				-- 2.층수
		, Max(STOP_PERCENT) AS STOP_PERCENT -- 3.비가동률
FROM (
 SELECT 
           POP_NO
		 , Layer AS Layer
		 , Convert(numeric(13,2), ROUND( ((WORKING_TIME / TIMESPAN) * 100) /60,2)) AS STOP_PERCENT 

  FROM(

        SELECT  -- OQC.ITEM_CODE
		     TRIM(OQC.POP_NO) AS POP_NO
		   , Max(Layers.C_NAME) AS Layer  
		   , SUM(Convert(numeric(13,2), OQC.INSP_WORKING_TIME)* 60)  AS WORKING_TIME -- 가동시간(초)
		   , SUM(Convert(numeric(13,2), QC.TIMESPAN)* 60) AS TIMESPAN
		   
		FROM [mesuser].[QM_OQC_MASTER] AS OQC   -- 출하검사
			   , [mesuser].[MM_QC_DOWNTIME] AS QC --품질 비가동 
			   , [dbo].[VW_Layers] AS Layers
		  WHERE 1=1		  
		  AND TRIM(OQC.POP_NO) = TRIM(QC.POPNO)
		  AND Layers.POPNO = OQC.POP_NO
		  AND ( isnull(@WORKDATE_S,'')=''OR (CONVERT(CHAR(10), OQC.TEST_DATE, 23) >= @WORKDATE_S))
          AND ( isnull(@WORKDATE_E,'')=''OR (CONVERT(CHAR(10), OQC.TEST_DATE, 23) <= @WORKDATE_E))
		  GrOUP BY TRIM(POP_NO) 
	UNION
	   SELECT  --  OQC.ITEM_CODE
		     TRIM(MQC.POP_NO) AS POP_NO
		   , Max(Layers.C_NAME) AS Layer  
		   , SUM(Convert(numeric(13,2), MQC.INSP_WORKING_TIME)* 60)  AS WORKING_TIME -- 가동시간(초)
		   , SUM(Convert(numeric(13,2), QC.TIMESPAN)* 60) AS TIMESPAN
		   
		FROM [mesuser].[QM_MQC_MASTER] AS MQC   -- 최종검사
			   , [mesuser].[MM_QC_DOWNTIME] AS QC --품질 비가동 
			   , [dbo].[VW_Layers] AS Layers
		  WHERE 1=1		 
		  AND TRIM(MQC.POP_NO) = TRIM(QC.POPNO)
		  AND Layers.POPNO = MQC.POP_NO
		  AND ( isnull(@WORKDATE_S,'')=''OR (CONVERT(CHAR(10), MQC.TEST_DATE, 23) >= @WORKDATE_S))
          AND ( isnull(@WORKDATE_E,'')=''OR (CONVERT(CHAR(10), MQC.TEST_DATE, 23) <= @WORKDATE_E))
		  GrOUP BY TRIM(POP_NO)
	UNION
	   SELECT  -- OQC.ITEM_CODE
		    TRIM(IQC.POP_NO) AS POP_NO
		   , Max(Layers.C_NAME) AS Layer  
		   , SUM(Convert(numeric(13,2), IQC.INSP_WORKING_TIME)* 60)  AS WORKING_TIME -- 가동시간(초)
		   , SUM(Convert(numeric(13,2), QC.TIMESPAN)* 60) AS TIMESPAN
		   
		FROM [mesuser].[QM_IQC_MASTER] AS IQC   -- 수입검사
			   , [mesuser].[MM_QC_DOWNTIME] AS QC --품질 비가동 
			   , [dbo].[VW_Layers] AS Layers
		  WHERE 1=1		 
		  AND TRIM(IQC.POP_NO) = TRIM(QC.POPNO)
		  AND Layers.POPNO = IQC.POP_NO				
		  AND ( isnull(@WORKDATE_S,'')=''OR (CONVERT(CHAR(10), IQC.TEST_DATE, 23) >= @WORKDATE_S))
          AND ( isnull(@WORKDATE_E,'')=''OR (CONVERT(CHAR(10), IQC.TEST_DATE, 23) <= @WORKDATE_E))
		  GrOUP BY TRIM(POP_NO)
	
  ) AS O
  WHERE 1=1
  AND ( isnull(@Layer,'')=''OR (Layer = @Layer))
  AND ( isnull(@POPNO,'')=''OR (TRIM(POP_NO) = @POPNO)) 
 ) AS X
 GROUP by  POP_NO

END
