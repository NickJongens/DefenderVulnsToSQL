/****** Set the database to create the table in - <database> ******/
USE [<database>]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/****** Set the Table to create - <table> ******/
CREATE TABLE [dbo].[<table>](
    [Id] [nvarchar](max) NULL,
    [Name] [nvarchar](max) NULL,
    [Description] [nvarchar](max) NULL,
    [Severity] [nvarchar](max) NULL,
    [CvssV3] [nvarchar](max) NULL,
    [ExposedMachines] [int] NULL,
    [PublishedOn] [datetime] NULL,
    [UpdatedOn] [datetime] NULL,
    [PublicExploit] [bit] NULL,
    [ExploitVerified] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
