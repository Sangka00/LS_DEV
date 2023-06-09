USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_PI_CHART]    Script Date: 2023-03-22 오전 9:30:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,CHO Sang HO>
-- Create date: <2022-12-12>
-- Description:	<지시대비 실적현황_생산정보 차트>
-- =============================================
ALTER PROCEDURE [mesuser].[SP_DASH_PI_CHART] 
		 @WORKDATE_S			NVARCHAR(20)		-- 시작일
		,@WORKDATE_E            NVARCHAR(20)		-- 종료일
	    ,@ITEM_CODE             NVARCHAR(20)        -- 품번
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   	/* 지시/생산수량*/
SELECT 
  WO.WORK_ORDER_NO  AS WORK_ORDER_NO    -- 작업지시번호
 ,Convert(numeric(13,1),ISNULL(WO.ORDER_QUANTITY,0)) AS  ORDER_QUANTITY      --지시수량
 ,Convert(numeric(13,1), Round( (ISNULL(WO.ACCEPTANCE_QUANTITY,0) + ISNULL(WO.DEFECTIVE_QUANTITY,0) ),1)) AS TOTal_SUM --생산수량
FROM [PP_WORK_ORDER] WO
WHERE 
  WO.B_USE=1
  AND ( isnull(@WORKDATE_S,'')=''OR (WO.START_DATE >= @WORKDATE_S))
  AND ( isnull(@WORKDATE_E,'')=''OR (WO.START_DATE <= @WORKDATE_E))
  AND ( isnull(@WORKDATE_E,'')=''OR (WO.START_DATE <= @WORKDATE_E))
END
