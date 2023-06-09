﻿USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_JOB_List]    Script Date: 2023-03-21 오후 5:27:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Description:	<작업지시팝업,,>
-- =============================================
ALTER PROCEDURE [mesuser].[SP_DASH_JOB_List]
	-- Add the parameters for the stored procedure here
	@WORK_ORDER_NO NVARCHAR(20)--  작업지시 번호
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT 
     --    [WORK_ORDER_NO]       -- WORK_ORDER_NO
	 --  , [ORDER_TYPE]            -- 지시유형     
	  -- , [ORDER_QUANTITY] AS ORDER_QUANTITY  -- 지시수량
           [ERP_ORDER_NO]  AS WORK_ORDER_NO      -- 오더번호(ERP)
         , (SELECT C_NAME FROM mesuser.APP_LIBRARY_CODE  where B_OID =PO.ORDER_TYPE) as ORDER_TYPE --'자재유형'
	     , PO.PUBLISH_DATE AS PUBLISH_DATE  --발행일
		 , CONVERT(NUMERIC(5,0),[ORDER_QUANTITY]) AS ORDER_QUANTITY -- 지시수량
   
   
  FROM [ExPle_DEV].[mesuser].[PP_WORK_ORDER] PO
  WHERE B_USE=1
  AND ( isnull(@WORK_ORDER_NO,'')=''OR (ERP_ORDER_NO LIKE '%'+@WORK_ORDER_NO+'%'))
  AnD ERP_ORDER_NO is not null
END
