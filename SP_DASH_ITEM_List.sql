﻿USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_ITEM_List]    Script Date: 2023-03-21 오후 5:24:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [mesuser].[SP_DASH_ITEM_List] 
	 @ITEM_CODE    NVARCHAR(20)   --품목코드
	,@ITEM_NAME    NVARCHAR(20)   --품목명
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT 
          MI.ITEM_CODE
        , MI.ITEM_NAME
		--, MI.ITEM_UNIT
		, (SELECT C_NAME FROM mesuser.APP_LIBRARY_CODE where B_OID =MI.ITEM_TYPE) as ITEM_TYPE
	
  FROM [mesuser].[MI_ITEM] MI
  Where B_USE=1
  AND ( isnull(@ITEM_CODE,'')=''OR (ITEM_CODE LIKE '%'+@ITEM_CODE  +'%'))
    AND ( isnull(@ITEM_NAME,'')=''OR (ITEM_NAME LIKE '%'+ @ITEM_NAME +'%'))
END
