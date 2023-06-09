USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_MACHINE_LIST]    Script Date: 2023-03-21 오후 5:28:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 <Author.Hong Seoung jin>
-- Create date:  <2023-01-04>
-- Description:	 <설비팝업>
-- =============================================
ALTER PROCEDURE[mesuser].[SP_DASH_MACHINE_LIST] 
	 @MACHINE_CODE  NVARCHAR(20)   --설비코드
	,@MACHINE_NAME  NVARCHAR(20)   --설비명
  	,@MACHINE_TYPE  NVARCHAR(20)   --설비유형
AS
BEGIN

	SET NOCOUNT ON;
	SELECT MACHINE_CODE, MACHINE_NAME, (Select C_NAME from mesuser.APP_LIBRARY_CODE where B_OID = MACHINE_TYPE) as MACHINE_TYPE
    FROM [mesuser].MI_MACHINE

	Where B_USE=1
  AND ( isnull(@MACHINE_CODE,'')=''OR (MACHINE_CODE LIKE '%'+ @MACHINE_CODE +'%'))
  AND ( isnull(@MACHINE_NAME,'')=''OR (MACHINE_NAME LIKE '%'+ @MACHINE_NAME +'%'))
  AND ( isnull(@MACHINE_TYPE,'')=''OR (MACHINE_TYPE LIKE '%'+ @MACHINE_TYPE +'%'))
END
