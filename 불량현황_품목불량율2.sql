USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_MES_ID_R_R]    Script Date: 2023-03-22 오전 9:12:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,CHO, Sang HO>
-- Create date: <2022-12-14,,>
-- Description:	<불량현황_품목불량율,MES_ID_R,>
-- =============================================
ALTER PROCEDURE [mesuser].[SP_DASH_MES_ID_R_R]
	     @WORKDATE_S			NVARCHAR(20)		-- 시작일
		,@WORKDATE_E            NVARCHAR(20)		-- 종료일
	    ,@MACHINE               NVARCHAR(20)     --설비
		,@PROCESSCODE           NVARCHAR(20)   --공정
AS
BEGIN
	
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	  SELECT ITem_Code, ITEM_NAME,SUM_QTY,SUM_IN_QTY, SUM_BAD_QTY
    , ROUND(CONVERT(float,SUM_BAD_QTY)/ sum(SUM_BAD_QTY) OVER(),2) * 100 AS BAD_PER
	FROM(
		  SELECT
		(
			CASE WHEN GROUPING( PP.ITemCode)= 1 THEN '합계'
			ELSE
				CONVERT(CHAR(10),  PP.ITemCode, 23)
			END
		 ) AS ITem_Code
		 ,
		 (
		   CASE WHEN GROUPING( PP.ITemCode)= 1 THEN ''
		   ELSE
			   Max(MI.ITEM_NAME) 
		   END
		  ) AS ITEM_NAME
		, SUM(PP.ALL_QTY) AS SUM_QTY
		, SUM(PP.IN_QTY)  AS SUM_IN_QTY
		, SUM(PP.BAD_QTY) AS SUM_BAD_QTY
	
		  FROM PP_WORK_RESULT PP, MI_ITEM  MI
		  WHERE
		   PP.ITEMCODE =   MI.ITEM_CODE 
		 AND ( isnull(@WORKDATE_S,'')=''OR (PP.WORKDATE >= @WORKDATE_S))
         AND ( isnull(@WORKDATE_E,'')=''OR (PP.WORKDATE<= @WORKDATE_E))
	     AND ( isnull(@MACHINE,'')=''OR  (PP.MACHINE =@MACHINE))
	     AND ( isnull(@PROCESSCODE,'')=''OR  (PP.PROCESSCODE =@PROCESSCODE))
		 GROUP BY (PP.ITEMCODE) 
		--  With RoLLUP
	) AS MM
END
