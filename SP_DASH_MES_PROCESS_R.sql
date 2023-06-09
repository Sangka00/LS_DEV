USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_MES_PROCESS_R]    Script Date: 2023-03-22 오전 9:27:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,CHO, Sang HO>
-- Create date: <2023-01-04,>
-- Description:	<공정 리스트 ,,>
-- =============================================
ALTER PROCEDURE[mesuser].[SP_DASH_MES_PROCESS_R] 
	-- Add the parameters for the stored procedure here
	 @PROCESS_CODE    NVARCHAR(20)   --MPROCESS코드
	,@PROCESS_NAME    NVARCHAR(20)   --MPROCESS_NAME명
	 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT MPROCESS_CODE, MPROCESS_NAME
    FRom [mesuser].MI_MPROCESS
	
	Where B_USE=1
	AND ( isnull(@PROCESS_CODE,'')=''OR (MPROCESS_CODE LIKE '%'+@PROCESS_CODE  +'%'))
    AND ( isnull(@PROCESS_NAME,'')=''OR (MPROCESS_NAME LIKE '%'+ @PROCESS_NAME +'%'))
END
