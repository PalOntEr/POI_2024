﻿/*
Deployment script for POI_2024

This code was generated by a tool.
Changes to this file may cause incorrect behavior and will be lost if
the code is regenerated.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "POI_2024"
:setvar DefaultFilePrefix "POI_2024"
:setvar DefaultDataPath "C:\Program Files\Microsoft SQL Server\MSSQL13.SQLEXPRESS\MSSQL\DATA\"
:setvar DefaultLogPath "C:\Program Files\Microsoft SQL Server\MSSQL13.SQLEXPRESS\MSSQL\DATA\"

GO
:on error exit
GO
/*
Detect SQLCMD mode and disable script execution if SQLCMD mode is not supported.
To re-enable the script after enabling SQLCMD mode, execute the following:
SET NOEXEC OFF; 
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'SQLCMD mode must be enabled to successfully execute this script.';
        SET NOEXEC ON;
    END


GO

IF (DB_ID(N'$(DatabaseName)') IS NOT NULL)
BEGIN
    DECLARE @rc      int,                       -- return code
            @fn      nvarchar(4000),            -- file name for back up
            @dir     nvarchar(4000)             -- backup directory

    EXEC @rc = [master].[dbo].[xp_instance_regread] N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'BackupDirectory', @dir output, 'no_output'
    if (@rc = 0) SELECT @dir = @dir + N'\'

    IF (@dir IS NULL)
    BEGIN 
        EXEC @rc = [master].[dbo].[xp_instance_regread] N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'DefaultData', @dir output, 'no_output'
        if (@rc = 0) SELECT @dir = @dir + N'\'
    END

    IF (@dir IS NULL)
    BEGIN
        EXEC @rc = [master].[dbo].[xp_instance_regread] N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\Setup', N'SQLDataRoot', @dir output, 'no_output'
        if (@rc = 0) SELECT @dir = @dir + N'\Backup\'
    END

    IF (@dir IS NULL)
    BEGIN
        SELECT @dir = N'$(DefaultDataPath)'
    END

    SELECT  @fn = @dir + N'$(DatabaseName)' + N'-' + 
            CONVERT(nchar(8), GETDATE(), 112) + N'-' + 
            RIGHT(N'0' + RTRIM(CONVERT(nchar(2), DATEPART(hh, GETDATE()))), 2) + 
            RIGHT(N'0' + RTRIM(CONVERT(nchar(2), DATEPART(mi, getdate()))), 2) + 
            RIGHT(N'0' + RTRIM(CONVERT(nchar(2), DATEPART(ss, getdate()))), 2) + 
            N'.bak' 
            BACKUP DATABASE [$(DatabaseName)] TO DISK = @fn
END
GO
USE [master];


GO

IF (DB_ID(N'$(DatabaseName)') IS NOT NULL) 
BEGIN
    ALTER DATABASE [$(DatabaseName)]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [$(DatabaseName)];
END

GO
PRINT N'Creating database $(DatabaseName)...'
GO
CREATE DATABASE [$(DatabaseName)]
    ON 
    PRIMARY(NAME = [$(DatabaseName)], FILENAME = N'$(DefaultDataPath)$(DefaultFilePrefix)_Primary.mdf')
    LOG ON (NAME = [$(DatabaseName)_log], FILENAME = N'$(DefaultLogPath)$(DefaultFilePrefix)_Primary.ldf') COLLATE SQL_Latin1_General_CP1_CI_AS
GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET AUTO_CLOSE OFF 
            WITH ROLLBACK IMMEDIATE;
    END


GO
USE [$(DatabaseName)];


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET ANSI_NULLS ON,
                ANSI_PADDING ON,
                ANSI_WARNINGS ON,
                ARITHABORT ON,
                CONCAT_NULL_YIELDS_NULL ON,
                NUMERIC_ROUNDABORT OFF,
                QUOTED_IDENTIFIER ON,
                ANSI_NULL_DEFAULT ON,
                CURSOR_DEFAULT LOCAL,
                RECOVERY FULL,
                CURSOR_CLOSE_ON_COMMIT OFF,
                AUTO_CREATE_STATISTICS ON,
                AUTO_SHRINK OFF,
                AUTO_UPDATE_STATISTICS ON,
                RECURSIVE_TRIGGERS OFF 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET ALLOW_SNAPSHOT_ISOLATION OFF;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET READ_COMMITTED_SNAPSHOT OFF 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET AUTO_UPDATE_STATISTICS_ASYNC OFF,
                PAGE_VERIFY NONE,
                DATE_CORRELATION_OPTIMIZATION OFF,
                DISABLE_BROKER,
                PARAMETERIZATION SIMPLE,
                SUPPLEMENTAL_LOGGING OFF 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF IS_SRVROLEMEMBER(N'sysadmin') = 1
    BEGIN
        IF EXISTS (SELECT 1
                   FROM   [master].[dbo].[sysdatabases]
                   WHERE  [name] = N'$(DatabaseName)')
            BEGIN
                EXECUTE sp_executesql N'ALTER DATABASE [$(DatabaseName)]
    SET TRUSTWORTHY OFF,
        DB_CHAINING OFF 
    WITH ROLLBACK IMMEDIATE';
            END
    END
ELSE
    BEGIN
        PRINT N'The database settings cannot be modified. You must be a SysAdmin to apply these settings.';
    END


GO
IF IS_SRVROLEMEMBER(N'sysadmin') = 1
    BEGIN
        IF EXISTS (SELECT 1
                   FROM   [master].[dbo].[sysdatabases]
                   WHERE  [name] = N'$(DatabaseName)')
            BEGIN
                EXECUTE sp_executesql N'ALTER DATABASE [$(DatabaseName)]
    SET HONOR_BROKER_PRIORITY OFF 
    WITH ROLLBACK IMMEDIATE';
            END
    END
ELSE
    BEGIN
        PRINT N'The database settings cannot be modified. You must be a SysAdmin to apply these settings.';
    END


GO
ALTER DATABASE [$(DatabaseName)]
    SET TARGET_RECOVERY_TIME = 0 SECONDS 
    WITH ROLLBACK IMMEDIATE;


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET FILESTREAM(NON_TRANSACTED_ACCESS = OFF),
                CONTAINMENT = NONE 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET AUTO_CREATE_STATISTICS ON(INCREMENTAL = OFF),
                MEMORY_OPTIMIZED_ELEVATE_TO_SNAPSHOT = OFF,
                DELAYED_DURABILITY = DISABLED 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET QUERY_STORE (QUERY_CAPTURE_MODE = ALL, DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_PLANS_PER_QUERY = 200, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 367), MAX_STORAGE_SIZE_MB = 100) 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET QUERY_STORE = OFF 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
        ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
        ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
        ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;
        ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
        ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY;
        ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
        ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY;
    END


GO
IF fulltextserviceproperty(N'IsFulltextInstalled') = 1
    EXECUTE sp_fulltext_database 'enable';


GO
PRINT N'Creating Table [dbo].[Archivos]...';


GO
CREATE TABLE [dbo].[Archivos] (
    [ID_Archivo]    INT             IDENTITY (1, 1) NOT NULL,
    [Nombre]        VARCHAR (255)   NOT NULL,
    [MIMEType]      VARCHAR (255)   NOT NULL,
    [Tamano]        INT             NOT NULL,
    [Contenido]     VARBINARY (MAX) NOT NULL,
    [FechaRegistro] DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([ID_Archivo] ASC)
);


GO
PRINT N'Creating Table [dbo].[ArchivosTareas]...';


GO
CREATE TABLE [dbo].[ArchivosTareas] (
    [Matricula]  INT NOT NULL,
    [ID_Archivo] INT NOT NULL,
    [ID_Tarea]   INT NOT NULL,
    PRIMARY KEY CLUSTERED ([Matricula] ASC, [ID_Archivo] ASC, [ID_Tarea] ASC)
);


GO
PRINT N'Creating Table [dbo].[Chats]...';


GO
CREATE TABLE [dbo].[Chats] (
    [ID_Chat]        INT           IDENTITY (1, 1) NOT NULL,
    [Nombre]         VARCHAR (100) NULL,
    [UsuarioAdmin]   INT           NULL,
    [ID_ArchivoFoto] INT           NULL,
    PRIMARY KEY CLUSTERED ([ID_Chat] ASC)
);


GO
PRINT N'Creating Table [dbo].[ChatsUsuarios]...';


GO
CREATE TABLE [dbo].[ChatsUsuarios] (
    [ID_ChatUsuario] INT IDENTITY (1, 1) NOT NULL,
    [ID_Chat]        INT NULL,
    [Integrante]     INT NULL,
    PRIMARY KEY CLUSTERED ([ID_ChatUsuario] ASC)
);


GO
PRINT N'Creating Table [dbo].[Mensajes]...';


GO
CREATE TABLE [dbo].[Mensajes] (
    [ID_Mensaje]    INT      IDENTITY (1, 1) NOT NULL,
    [UsuarioEmisor] INT      NOT NULL,
    [ChatReceptor]  INT      NOT NULL,
    [Mensaje]       TEXT     NULL,
    [FechaEnvio]    DATETIME NOT NULL,
    [ID_Archivo]    INT      NULL,
    PRIMARY KEY CLUSTERED ([ID_Mensaje] ASC)
);


GO
PRINT N'Creating Table [dbo].[Premios]...';


GO
CREATE TABLE [dbo].[Premios] (
    [ID_Premio]        INT IDENTITY (1, 1) NOT NULL,
    [ID_ArchivoPremio] INT NULL,
    [Costo]            INT NOT NULL,
    PRIMARY KEY CLUSTERED ([ID_Premio] ASC)
);


GO
PRINT N'Creating Table [dbo].[Tareas]...';


GO
CREATE TABLE [dbo].[Tareas] (
    [ID_Tareas]         INT          IDENTITY (1, 1) NOT NULL,
    [ID_Chat]           INT          NULL,
    [FechaCreacion]     DATETIME     NULL,
    [FechaFinalizacion] DATETIME     NULL,
    [Descripcion]       TEXT         NOT NULL,
    [Nombre]            VARCHAR (30) NOT NULL,
    [Estatus]           INT          NOT NULL,
    [CalCoins]          INT          NOT NULL,
    PRIMARY KEY CLUSTERED ([ID_Tareas] ASC)
);


GO
PRINT N'Creating Table [dbo].[Usuarios]...';


GO
CREATE TABLE [dbo].[Usuarios] (
    [Matricula]      INT           NOT NULL,
    [NombreCompleto] VARCHAR (200) NOT NULL,
    [Contrasena]     VARCHAR (150) NOT NULL,
    [ID_ArchivoFoto] INT           NULL,
    [CalCoins]       INT           NOT NULL,
    PRIMARY KEY CLUSTERED ([Matricula] ASC)
);


GO
PRINT N'Creating Table [dbo].[UsuariosPremios]...';


GO
CREATE TABLE [dbo].[UsuariosPremios] (
    [UsuarioPremio] INT IDENTITY (1, 1) NOT NULL,
    [Matricula]     INT NULL,
    [ID_Premio]     INT NULL,
    PRIMARY KEY CLUSTERED ([UsuarioPremio] ASC)
);


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[Archivos]...';


GO
ALTER TABLE [dbo].[Archivos]
    ADD DEFAULT (getdate()) FOR [FechaRegistro];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[Mensajes]...';


GO
ALTER TABLE [dbo].[Mensajes]
    ADD DEFAULT (getdate()) FOR [FechaEnvio];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[Tareas]...';


GO
ALTER TABLE [dbo].[Tareas]
    ADD DEFAULT (getdate()) FOR [FechaCreacion];


GO
PRINT N'Creating Default Constraint unnamed constraint on [dbo].[Usuarios]...';


GO
ALTER TABLE [dbo].[Usuarios]
    ADD DEFAULT ((0)) FOR [CalCoins];


GO
PRINT N'Creating Foreign Key unnamed constraint on [dbo].[ArchivosTareas]...';


GO
ALTER TABLE [dbo].[ArchivosTareas]
    ADD FOREIGN KEY ([ID_Archivo]) REFERENCES [dbo].[Archivos] ([ID_Archivo]);


GO
PRINT N'Creating Foreign Key unnamed constraint on [dbo].[ArchivosTareas]...';


GO
ALTER TABLE [dbo].[ArchivosTareas]
    ADD FOREIGN KEY ([ID_Tarea]) REFERENCES [dbo].[Tareas] ([ID_Tareas]);


GO
PRINT N'Creating Foreign Key unnamed constraint on [dbo].[ArchivosTareas]...';


GO
ALTER TABLE [dbo].[ArchivosTareas]
    ADD FOREIGN KEY ([Matricula]) REFERENCES [dbo].[Usuarios] ([Matricula]);


GO
PRINT N'Creating Foreign Key unnamed constraint on [dbo].[Chats]...';


GO
ALTER TABLE [dbo].[Chats]
    ADD FOREIGN KEY ([ID_ArchivoFoto]) REFERENCES [dbo].[Archivos] ([ID_Archivo]);


GO
PRINT N'Creating Foreign Key unnamed constraint on [dbo].[Chats]...';


GO
ALTER TABLE [dbo].[Chats]
    ADD FOREIGN KEY ([UsuarioAdmin]) REFERENCES [dbo].[Usuarios] ([Matricula]);


GO
PRINT N'Creating Foreign Key unnamed constraint on [dbo].[ChatsUsuarios]...';


GO
ALTER TABLE [dbo].[ChatsUsuarios]
    ADD FOREIGN KEY ([ID_Chat]) REFERENCES [dbo].[Chats] ([ID_Chat]);


GO
PRINT N'Creating Foreign Key unnamed constraint on [dbo].[ChatsUsuarios]...';


GO
ALTER TABLE [dbo].[ChatsUsuarios]
    ADD FOREIGN KEY ([Integrante]) REFERENCES [dbo].[Usuarios] ([Matricula]);


GO
PRINT N'Creating Foreign Key unnamed constraint on [dbo].[Mensajes]...';


GO
ALTER TABLE [dbo].[Mensajes]
    ADD FOREIGN KEY ([ID_Archivo]) REFERENCES [dbo].[Archivos] ([ID_Archivo]);


GO
PRINT N'Creating Foreign Key unnamed constraint on [dbo].[Mensajes]...';


GO
ALTER TABLE [dbo].[Mensajes]
    ADD FOREIGN KEY ([ChatReceptor]) REFERENCES [dbo].[Chats] ([ID_Chat]);


GO
PRINT N'Creating Foreign Key unnamed constraint on [dbo].[Mensajes]...';


GO
ALTER TABLE [dbo].[Mensajes]
    ADD FOREIGN KEY ([UsuarioEmisor]) REFERENCES [dbo].[Usuarios] ([Matricula]);


GO
PRINT N'Creating Foreign Key unnamed constraint on [dbo].[Premios]...';


GO
ALTER TABLE [dbo].[Premios]
    ADD FOREIGN KEY ([ID_ArchivoPremio]) REFERENCES [dbo].[Archivos] ([ID_Archivo]);


GO
PRINT N'Creating Foreign Key unnamed constraint on [dbo].[Tareas]...';


GO
ALTER TABLE [dbo].[Tareas]
    ADD FOREIGN KEY ([ID_Chat]) REFERENCES [dbo].[Chats] ([ID_Chat]);


GO
PRINT N'Creating Foreign Key unnamed constraint on [dbo].[Usuarios]...';


GO
ALTER TABLE [dbo].[Usuarios]
    ADD FOREIGN KEY ([ID_ArchivoFoto]) REFERENCES [dbo].[Archivos] ([ID_Archivo]);


GO
PRINT N'Creating Foreign Key unnamed constraint on [dbo].[UsuariosPremios]...';


GO
ALTER TABLE [dbo].[UsuariosPremios]
    ADD FOREIGN KEY ([ID_Premio]) REFERENCES [dbo].[Premios] ([ID_Premio]);


GO
PRINT N'Creating Foreign Key unnamed constraint on [dbo].[UsuariosPremios]...';


GO
ALTER TABLE [dbo].[UsuariosPremios]
    ADD FOREIGN KEY ([Matricula]) REFERENCES [dbo].[Usuarios] ([Matricula]);


GO
PRINT N'Creating Procedure [dbo].[sp_Archivos]...';


GO
CREATE PROCEDURE [dbo].[sp_Archivos]
	@Op TINYINT,
	@ID_Archivo INT = NULL,
	@Nombre VARCHAR(255) = NULL,
	@MIMEType VARCHAR(255) = NULL,
	@Tamano INT = NULL,
	@Contenido VARBINARY(MAX) = NULL,
	@UploadType TINYINT = NULL,
	@UploadedTo INT = NULL,
	@UploadedBy INT = NULL
AS
BEGIN
	IF @Op = 1
	BEGIN
		INSERT INTO [dbo].[Archivos] (Nombre,MIMEType,Tamano, Contenido)
		VALUES (@Nombre,@MIMEType, @Tamano, @Contenido)
		--IF (@UploadType = 1 AND @UploadedTo IS NOT NULL AND @UploadedBy IS NOT NULL) --Si se subi� a un chat y por un usuario ejecutar procedure para insertar mensaje
		--	EXEC sp_Mensaje 1, @UploadedBy, @UploadedTo, @Nombre, ;
		--ELSE
		--IF (@UploadType = 2 AND @UploadedTo IS NOT NULL AND @UploadedBy IS NOT NULL) --Si se subi� a un premio y por un usuario ejecutar procedure para insertar mensaje
		--	EXEC sp_Premios 1, @UploadedTo, @ID_Archivo, @Tamano;
	END

	ELSE IF @Op = 2
	BEGIN
		UPDATE [dbo].[Archivos]
		SET
			Nombre = ISNULL(@Nombre,Nombre),
			MIMEType = ISNULL(@MIMEType,MIMEType),
			Tamano = ISNULL(@Tamano,Tamano),
			Contenido = ISNULL(@Contenido,Contenido)
		WHERE
		ID_Archivo = @ID_Archivo
	END

	ELSE IF @Op = 3
	BEGIN
		DELETE FROM [dbo].[Archivos]
		WHERE ID_Archivo = @ID_Archivo
	END	

	ELSE IF @Op = 4
	BEGIN
		SELECT [ID_Archivo], [Nombre], [MIMEType], [Tamano], [Contenido], [FechaRegistro] FROM [dbo].[Archivos] WHERE
			(ISNULL(@ID_Archivo, [ID_Archivo]) = [ID_Archivo]) AND
			(ISNULL(@Nombre, [Nombre]) = [Nombre]) AND
			(ISNULL(@MIMEType, [MIMEType]) = [MIMEType]) AND
			(ISNULL(@Tamano, [Tamano]) = [Tamano]) AND
			(ISNULL(@Contenido, [Contenido]) = [Contenido])
	END
END
GO
PRINT N'Creating Procedure [dbo].[sp_Chats]...';


GO
CREATE PROCEDURE [dbo].[sp_Chats]
@Op TINYINT,
@ID_Chat INT = NULL,
@Nombre VARCHAR(100) = NULL,
@UsuarioAdmin INT = NULL,
@ID_ArchivoFoto INT = NULL
AS
BEGIN
	IF @Op = 1
	BEGIN
		INSERT INTO [dbo].[Chats] ([Nombre],[UsuarioAdmin],[ID_ArchivoFoto])
		VALUES (@Nombre,@UsuarioAdmin,@ID_ArchivoFoto);
	END
	ELSE IF @Op = 2
	BEGIN
		UPDATE [dbo].[Chats]
		SET
		[Nombre] = ISNULL(@Nombre,[Nombre]),
		[UsuarioAdmin] = ISNULL(@UsuarioAdmin,[UsuarioAdmin]),
		[ID_ArchivoFoto] = ISNULL(@ID_ArchivoFoto, [ID_ArchivoFoto] );
	END
	ELSE IF @Op = 3
	BEGIN
		DELETE FROM [dbo].[Chats]
		WHERE [ID_Chat] = @ID_Chat;
	END
	ELSE IF @Op = 4
	BEGIN 
	SELECT  [Nombre],[UsuarioAdmin],[ID_ArchivoFoto] FROM [dbo].[Chats]
	WHERE (ISNULL(@ID_Chat, [ID_Chat]) = [ID_Chat]) AND
	(ISNULL(@Nombre, [Nombre]) = [Nombre]) AND
	(ISNULL(@UsuarioAdmin, [UsuarioAdmin]) = [UsuarioAdmin]) AND
	(ISNULL(@ID_ArchivoFoto,[ID_ArchivoFoto]) = [ID_ArchivoFoto]);
	END
END
GO
PRINT N'Creating Procedure [dbo].[sp_Premios]...';


GO
CREATE PROCEDURE [dbo].[sp_Premios]
    @Op TINYINT,
    @ID_Premio INT = NULL,
    @ID_ArchivoPremio INT = NULL,
    @Costo INT = NULL
AS
BEGIN
    IF @Op = 1
    BEGIN
        INSERT INTO [dbo].[Premios] ([ID_ArchivoPremio], [Costo])
        VALUES (@ID_ArchivoPremio, @Costo);
    END

    ELSE IF @Op = 2
    BEGIN
        UPDATE [dbo].[Premios]
        SET [ID_ArchivoPremio] = ISNULL(@ID_ArchivoPremio, [ID_ArchivoPremio]),
            [Costo] = ISNULL(@Costo, [Costo])
        WHERE [ID_Premio] = @ID_Premio;
    END

    ELSE IF @Op = 3
    BEGIN
        DELETE FROM [dbo].[Premios]
        WHERE [ID_Premio] = @ID_Premio;
    END
    
    ELSE IF @Op = 4
    BEGIN
        SELECT [ID_Premio], [ID_ArchivoPremio], [Costo] FROM [dbo].[Premios] WHERE
            (ISNULL(@ID_Premio, [ID_Premio]) = [ID_Premio]) AND
            (ISNULL(@ID_ArchivoPremio, [ID_ArchivoPremio]) = [ID_ArchivoPremio]) AND
            (ISNULL(@Costo, [Costo]) = [Costo]);
    END
END
GO
PRINT N'Creating Procedure [dbo].[sp_Usuario]...';


GO
CREATE PROCEDURE [dbo].[sp_Usuario]
    @Op TINYINT,
    @Matricula INT = NULL,
    @NombreCompleto VARCHAR(200) = NULL,
    @Contrasena VARCHAR(150) = NULL,
    @ID_ArchivoFoto INT = NULL,
    @CalCoins INT = NULL
AS
BEGIN
    IF @Op = 1
    BEGIN
        INSERT INTO [dbo].[Usuarios] ([Matricula], [NombreCompleto], [Contrasena], [ID_ArchivoFoto], [CalCoins])
        VALUES (@Matricula, @NombreCompleto, @Contrasena, @ID_ArchivoFoto, @CalCoins);
    END

    ELSE IF @Op = 2
    BEGIN
        UPDATE [dbo].[Usuarios]
        SET [NombreCompleto] = ISNULL(@NombreCompleto, [NombreCompleto]),
            [Contrasena] = ISNULL(@Contrasena, [Contrasena]),
            [ID_ArchivoFoto] = ISNULL(@ID_ArchivoFoto, [ID_ArchivoFoto]),
            [CalCoins] = ISNULL(@CalCoins, [CalCoins])
        WHERE [Matricula] = @Matricula;
    END

    ELSE IF @Op = 3
    BEGIN
        DELETE FROM [dbo].[Usuarios]
        WHERE [Matricula] = @Matricula;
    END
    
    ELSE IF @Op = 4
    BEGIN
        SELECT [Matricula], [NombreCompleto], [Contrasena], [ID_ArchivoFoto], [CalCoins] FROM [dbo].[Usuarios] WHERE
            (ISNULL(@Matricula, [Matricula]) = [Matricula]) AND
            (ISNULL(@NombreCompleto, [NombreCompleto]) = [NombreCompleto]) AND
            (ISNULL(@Contrasena, [Contrasena]) = [Contrasena]) AND
            (ISNULL(@ID_ArchivoFoto, [ID_ArchivoFoto]) = [ID_ArchivoFoto]) AND
            (ISNULL(@CalCoins, [CalCoins]) = [CalCoins]);
    END
END
GO
-- Refactoring step to update target server with deployed transaction logs

IF OBJECT_ID(N'dbo.__RefactorLog') IS NULL
BEGIN
    CREATE TABLE [dbo].[__RefactorLog] (OperationKey UNIQUEIDENTIFIER NOT NULL PRIMARY KEY)
    EXEC sp_addextendedproperty N'microsoft_database_tools_support', N'refactoring log', N'schema', N'dbo', N'table', N'__RefactorLog'
END
GO
IF NOT EXISTS (SELECT OperationKey FROM [dbo].[__RefactorLog] WHERE OperationKey = '162af853-dd34-4772-bdd3-007a1fc09eee')
INSERT INTO [dbo].[__RefactorLog] (OperationKey) values ('162af853-dd34-4772-bdd3-007a1fc09eee')

GO

GO
-- Insert dummy data into database

INSERT INTO Archivos (Nombre, MIMEType, Tamano, Contenido, FechaRegistro)
VALUES ('Archivo1', 'image/jpeg', 1024, 0x0123456789ABCDEF, GETDATE());

INSERT INTO Usuarios (Matricula, NombreCompleto, Contrasena, ID_ArchivoFoto, CalCoins)
VALUES (123456, 'John Doe', 'password123', 1, 100);

INSERT INTO Premios (ID_ArchivoPremio, Costo)
VALUES (1, 50);

INSERT INTO UsuariosPremios (Matricula, ID_Premio)
VALUES (123456, 1);

INSERT INTO Chats (Nombre, UsuarioAdmin, ID_ArchivoFoto)
VALUES ('Chat1', 123456, 1);

INSERT INTO ChatsUsuarios (ID_Chat, Integrante)
VALUES (1, 123456);

INSERT INTO Mensajes (UsuarioEmisor, ChatReceptor, Mensaje, Archivo)
VALUES (123456, 1, 'Hello', 1);

INSERT INTO Tareas (ID_Chat, FechaCreacion, Descripcion, Nombre, Estatus, CalCoins)
VALUES (1, GETDATE(), 'Task 1', 'Task 1', 1, 10);

INSERT INTO ArchivosTareas (Matricula, ID_Archivo, ID_Tarea)
VALUES (123456, 1, 1);

INSERT INTO Archivos (Nombre, MIMEType, Tamano, Contenido, FechaRegistro)
VALUES ('Archivo2', 'image/png', 2048, 0xABCDEF0123456789, GETDATE());

INSERT INTO Usuarios (Matricula, NombreCompleto, Contrasena, ID_ArchivoFoto, CalCoins)
VALUES (654321, 'Jane Smith', 'password456', 2, 200);

INSERT INTO Premios (ID_ArchivoPremio, Costo)
VALUES (2, 100);

INSERT INTO UsuariosPremios (Matricula, ID_Premio)
VALUES (654321, 2);

INSERT INTO Chats (Nombre, UsuarioAdmin, ID_ArchivoFoto)
VALUES ('Chat2', 654321, 2);

INSERT INTO ChatsUsuarios (ID_Chat, Integrante)
VALUES (2, 654321);

INSERT INTO Mensajes (UsuarioEmisor, ChatReceptor, Mensaje, Archivo)
VALUES (654321, 2, 'Hi', 2);

INSERT INTO Tareas (ID_Chat, FechaCreacion, Descripcion, Nombre, Estatus, CalCoins)
VALUES (2, GETDATE(), 'Task 2', 'Task 2', 1, 20);

INSERT INTO ArchivosTareas (Matricula, ID_Archivo, ID_Tarea)
VALUES (654321, 2, 2);

INSERT INTO Archivos (Nombre, MIMEType, Tamano, Contenido, FechaRegistro)
VALUES ('Archivo3', 'image/jpeg', 3072, 0x0123456789ABCDEF, GETDATE());

INSERT INTO Usuarios (Matricula, NombreCompleto, Contrasena, ID_ArchivoFoto, CalCoins)
VALUES (789012, 'Alice Johnson', 'password789', 3, 300);

INSERT INTO Premios (ID_ArchivoPremio, Costo)
VALUES (3, 150);

INSERT INTO UsuariosPremios (Matricula, ID_Premio)
VALUES (789012, 3);

INSERT INTO Chats (Nombre, UsuarioAdmin, ID_ArchivoFoto)
VALUES ('Chat3', 789012, 3);

INSERT INTO ChatsUsuarios (ID_Chat, Integrante)
VALUES (3, 789012);

INSERT INTO Mensajes (UsuarioEmisor, ChatReceptor, Mensaje, Archivo)
VALUES (789012, 3, 'Hey', 3);

INSERT INTO Tareas (ID_Chat, FechaCreacion, Descripcion, Nombre, Estatus, CalCoins)
VALUES (3, GETDATE(), 'Task 3', 'Task 3', 1, 30);

INSERT INTO ArchivosTareas (Matricula, ID_Archivo, ID_Tarea)
VALUES (789012, 3, 3);

INSERT INTO Archivos (Nombre, MIMEType, Tamano, Contenido, FechaRegistro)
VALUES ('Archivo4', 'image/png', 4096, 0xABCDEF0123456789, GETDATE());

INSERT INTO Usuarios (Matricula, NombreCompleto, Contrasena, ID_ArchivoFoto, CalCoins)
VALUES (345678, 'Bob Williams', 'password012', 4, 400);

INSERT INTO Premios (ID_ArchivoPremio, Costo)
VALUES (4, 200);

INSERT INTO UsuariosPremios (Matricula, ID_Premio)
VALUES (345678, 4);

INSERT INTO Chats (Nombre, UsuarioAdmin, ID_ArchivoFoto)
VALUES ('Chat4', 345678, 4);

INSERT INTO ChatsUsuarios (ID_Chat, Integrante)
VALUES (4, 345678);

INSERT INTO Mensajes (UsuarioEmisor, ChatReceptor, Mensaje, Archivo)
VALUES (345678, 4, 'Hola', 4);

INSERT INTO Tareas (ID_Chat, FechaCreacion, Descripcion, Nombre, Estatus, CalCoins)
VALUES (4, GETDATE(), 'Task 4', 'Task 4', 1, 40);

INSERT INTO ArchivosTareas (Matricula, ID_Archivo, ID_Tarea)
VALUES (345678, 4, 4);

INSERT INTO Archivos (Nombre, MIMEType, Tamano, Contenido, FechaRegistro)
VALUES ('Archivo5', 'image/jpeg', 5120, 0x0123456789ABCDEF, GETDATE());

INSERT INTO Usuarios (Matricula, NombreCompleto, Contrasena, ID_ArchivoFoto, CalCoins)
VALUES (567890, 'Charlie Brown', 'password345', 5, 500);

INSERT INTO Premios (ID_ArchivoPremio, Costo)
VALUES (5, 250);

INSERT INTO UsuariosPremios (Matricula, ID_Premio)
VALUES (567890, 5);

INSERT INTO Chats (Nombre, UsuarioAdmin, ID_ArchivoFoto)
VALUES ('Chat5', 567890, 5);

INSERT INTO ChatsUsuarios (ID_Chat, Integrante)
VALUES (5, 567890);

INSERT INTO Mensajes (UsuarioEmisor, ChatReceptor, Mensaje, Archivo)
VALUES (567890, 5, 'Greetings', 5);

INSERT INTO Tareas (ID_Chat, FechaCreacion, Descripcion, Nombre, Estatus, CalCoins)
VALUES (5, GETDATE(), 'Task 5', 'Task 5', 1, 50);

INSERT INTO ArchivosTareas (Matricula, ID_Archivo, ID_Tarea)
VALUES (567890, 5, 5);

INSERT INTO Archivos (Nombre, MIMEType, Tamano, Contenido, FechaRegistro)
VALUES ('Archivo6', 'image/png', 6144, 0xABCDEF0123456789, GETDATE());

INSERT INTO Usuarios (Matricula, NombreCompleto, Contrasena, ID_ArchivoFoto, CalCoins)
VALUES (678901, 'David Smith', 'password678', 6, 600);

INSERT INTO Premios (ID_ArchivoPremio, Costo)
VALUES (6, 300);

INSERT INTO UsuariosPremios (Matricula, ID_Premio)
VALUES (678901, 6);

INSERT INTO Chats (Nombre, UsuarioAdmin, ID_ArchivoFoto)
VALUES ('Chat6', 678901, 6);

INSERT INTO ChatsUsuarios (ID_Chat, Integrante)
VALUES (6, 678901);

INSERT INTO Mensajes (UsuarioEmisor, ChatReceptor, Mensaje, Archivo)
VALUES (678901, 6, 'Howdy', 6);

INSERT INTO Tareas (ID_Chat, FechaCreacion, Descripcion, Nombre, Estatus, CalCoins)
VALUES (6, GETDATE(), 'Task 6', 'Task 6', 1, 60);

INSERT INTO ArchivosTareas (Matricula, ID_Archivo, ID_Tarea)
VALUES (678901, 6, 6);

INSERT INTO Archivos (Nombre, MIMEType, Tamano, Contenido, FechaRegistro)
VALUES ('Archivo7', 'image/jpeg', 7168, 0x0123456789ABCDEF, GETDATE());

INSERT INTO Usuarios (Matricula, NombreCompleto, Contrasena, ID_ArchivoFoto, CalCoins)
VALUES (789123, 'Eve Adams', 'password901', 7, 700);

INSERT INTO Premios (ID_ArchivoPremio, Costo)
VALUES (7, 350);

INSERT INTO UsuariosPremios (Matricula, ID_Premio)
VALUES (789123, 7);

INSERT INTO Chats (Nombre, UsuarioAdmin, ID_ArchivoFoto)
VALUES ('Chat7', 789123, 7);

INSERT INTO ChatsUsuarios (ID_Chat, Integrante)
VALUES (7, 789123);

INSERT INTO Mensajes (UsuarioEmisor, ChatReceptor, Mensaje, Archivo)
VALUES (789123, 7, 'Hi there', 7);

INSERT INTO Tareas (ID_Chat, FechaCreacion, Descripcion, Nombre, Estatus, CalCoins)
VALUES (7, GETDATE(), 'Task 7', 'Task 7', 1, 70);

INSERT INTO ArchivosTareas (Matricula, ID_Archivo, ID_Tarea)
VALUES (789123, 7, 7);

INSERT INTO Archivos (Nombre, MIMEType, Tamano, Contenido, FechaRegistro)
VALUES ('Archivo8', 'image/png', 8192, 0xABCDEF0123456789, GETDATE());

INSERT INTO Usuarios (Matricula, NombreCompleto, Contrasena, ID_ArchivoFoto, CalCoins)
VALUES (890123, 'Frank White', 'password234', 8, 800);

INSERT INTO Premios (ID_ArchivoPremio, Costo)
VALUES (8, 400);

INSERT INTO UsuariosPremios (Matricula, ID_Premio)
VALUES (890123, 8);

INSERT INTO Chats (Nombre, UsuarioAdmin, ID_ArchivoFoto)
VALUES ('Chat8', 890123, 8);

INSERT INTO ChatsUsuarios (ID_Chat, Integrante)
VALUES (8, 890123);

INSERT INTO Mensajes (UsuarioEmisor, ChatReceptor, Mensaje, Archivo)
VALUES (890123, 8, 'Hello there', 8);

INSERT INTO Tareas (ID_Chat, FechaCreacion, Descripcion, Nombre, Estatus, CalCoins)
VALUES (8, GETDATE(), 'Task 8', 'Task 8', 1, 80);

INSERT INTO ArchivosTareas (Matricula, ID_Archivo, ID_Tarea)
VALUES (890123, 8, 8);

INSERT INTO Archivos (Nombre, MIMEType, Tamano, Contenido, FechaRegistro)
VALUES ('Archivo9', 'image/jpeg', 9216, 0x0123456789ABCDEF, GETDATE());

INSERT INTO Usuarios (Matricula, NombreCompleto, Contrasena, ID_ArchivoFoto, CalCoins)
VALUES (901234, 'Grace Green', 'password567', 9, 900);

INSERT INTO Premios (ID_ArchivoPremio, Costo)
VALUES (9, 450);

INSERT INTO UsuariosPremios (Matricula, ID_Premio)
VALUES (901234, 9);

INSERT INTO Chats (Nombre, UsuarioAdmin, ID_ArchivoFoto)
VALUES ('Chat9', 901234, 9);

INSERT INTO ChatsUsuarios (ID_Chat, Integrante)
VALUES (9, 901234);

INSERT INTO Mensajes (UsuarioEmisor, ChatReceptor, Mensaje, Archivo)
VALUES (901234, 9, 'Good day', 9);

INSERT INTO Tareas (ID_Chat, FechaCreacion, Descripcion, Nombre, Estatus, CalCoins)
VALUES (9, GETDATE(), 'Task 9', 'Task 9', 1, 90);

INSERT INTO ArchivosTareas (Matricula, ID_Archivo, ID_Tarea)
VALUES (901234, 9, 9);

INSERT INTO Archivos (Nombre, MIMEType, Tamano, Contenido, FechaRegistro)
VALUES ('Archivo10', 'image/png', 10240, 0xABCDEF0123456789, GETDATE());

INSERT INTO Usuarios (Matricula, NombreCompleto, Contrasena, ID_ArchivoFoto, CalCoins)
VALUES (123789, 'Hank Brown', 'password890', 10, 1000);

INSERT INTO Premios (ID_ArchivoPremio, Costo)
VALUES (10, 500);

INSERT INTO UsuariosPremios (Matricula, ID_Premio)
VALUES (123789, 10);

INSERT INTO Chats (Nombre, UsuarioAdmin, ID_ArchivoFoto)
VALUES ('Chat10', 123789, 10);

INSERT INTO ChatsUsuarios (ID_Chat, Integrante)
VALUES (10, 123789);

INSERT INTO Mensajes (UsuarioEmisor, ChatReceptor, Mensaje, Archivo)
VALUES (123789, 10, 'Hey there', 10);

INSERT INTO Tareas (ID_Chat, FechaCreacion, Descripcion, Nombre, Estatus, CalCoins)
VALUES (10, GETDATE(), 'Task 10', 'Task 10', 1, 100);

INSERT INTO ArchivosTareas (Matricula, ID_Archivo, ID_Tarea)
VALUES (123789, 10, 10);
GO

GO
DECLARE @VarDecimalSupported AS BIT;

SELECT @VarDecimalSupported = 0;

IF ((ServerProperty(N'EngineEdition') = 3)
    AND (((@@microsoftversion / power(2, 24) = 9)
          AND (@@microsoftversion & 0xffff >= 3024))
         OR ((@@microsoftversion / power(2, 24) = 10)
             AND (@@microsoftversion & 0xffff >= 1600))))
    SELECT @VarDecimalSupported = 1;

IF (@VarDecimalSupported > 0)
    BEGIN
        EXECUTE sp_db_vardecimal_storage_format N'$(DatabaseName)', 'ON';
    END


GO
PRINT N'Update complete.';


GO
