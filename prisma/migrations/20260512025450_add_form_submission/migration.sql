-- CreateTable
CREATE TABLE `AccountRole` (
    `id` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `description` VARCHAR(1000) NULL,
    `isSystemRole` BOOLEAN NOT NULL DEFAULT false,
    `level` INTEGER NOT NULL,
    `requiresTwoFactor` BOOLEAN NOT NULL DEFAULT false,
    `permissions` TEXT NULL,
    `metadataId` VARCHAR(191) NULL,

    UNIQUE INDEX `AccountRole_name_key`(`name`),
    UNIQUE INDEX `AccountRole_metadataId_key`(`metadataId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Account` (
    `id` VARCHAR(191) NOT NULL,
    `lastLogin` DATETIME(3) NOT NULL,
    `roleId` VARCHAR(191) NOT NULL,
    `status` ENUM('active', 'locked') NOT NULL DEFAULT 'active',
    `campus` ENUM('COMAYAGUA', 'YORO', 'TEGUCIGALPA', 'SANPEDRO', 'CHOLUTECA', 'OLANCHO', 'LA_CEIBA', 'DANLI', 'SANTA_ROSA') NOT NULL,
    `email` VARCHAR(191) NOT NULL,
    `emailVerified` BOOLEAN NOT NULL DEFAULT false,
    `emailLastChanged` DATETIME(3) NOT NULL,
    `emailVerificationToken` VARCHAR(191) NULL,
    `emailVerificationTokenExpires` DATETIME(3) NULL,
    `name` VARCHAR(191) NOT NULL,
    `tfaSecret` VARCHAR(191) NULL,
    `password` VARCHAR(191) NOT NULL,
    `forgotPasswordToken` VARCHAR(191) NULL,
    `forgotPasswordTokenExpires` DATETIME(3) NULL,
    `lastPasswordChange` DATETIME(3) NOT NULL,
    `metadataId` VARCHAR(191) NULL,

    UNIQUE INDEX `Account_email_key`(`email`),
    UNIQUE INDEX `Account_metadataId_key`(`metadataId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Metadata` (
    `id` VARCHAR(191) NOT NULL,
    `documentVersion` INTEGER NULL,
    `syncVersion` INTEGER NULL,
    `createdAt` DATETIME(3) NULL,
    `createdById` VARCHAR(191) NULL,
    `updatedAt` DATETIME(3) NULL,
    `updatedById` VARCHAR(191) NULL,
    `deleted` BOOLEAN NULL DEFAULT false,
    `deletedAt` DATETIME(3) NULL,
    `deletedById` VARCHAR(191) NULL,
    `status` ENUM('active', 'inactive') NULL,
    `source` ENUM('manual', 'imported') NULL,
    `notes` VARCHAR(2000) NULL,
    `tags` TEXT NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `MetadataUpdateHistory` (
    `id` VARCHAR(191) NOT NULL,
    `metadataId` VARCHAR(191) NOT NULL,
    `updatedAt` DATETIME(3) NOT NULL,
    `updatedById` VARCHAR(191) NULL,
    `changes` JSON NOT NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Config` (
    `id` VARCHAR(191) NOT NULL,
    `metadataId` VARCHAR(191) NULL,

    UNIQUE INDEX `Config_metadataId_key`(`metadataId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `sessions` (
    `id` VARCHAR(191) NOT NULL,
    `sid` VARCHAR(191) NOT NULL,
    `data` TEXT NOT NULL,
    `expiresAt` DATETIME(3) NOT NULL,

    UNIQUE INDEX `sessions_sid_key`(`sid`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Log` (
    `id` VARCHAR(191) NOT NULL,
    `date` DATETIME(3) NOT NULL,
    `source` VARCHAR(191) NOT NULL,
    `level` ENUM('info', 'warning', 'error', 'critical', 'debug', 'important') NOT NULL,
    `message` TEXT NOT NULL,
    `duration` INTEGER NULL,
    `details` JSON NULL,
    `traceId` VARCHAR(191) NULL,
    `references` JSON NULL,

    INDEX `Log_date_idx`(`date`),
    INDEX `Log_level_idx`(`level`),
    INDEX `Log_traceId_idx`(`traceId`),
    INDEX `Log_source_idx`(`source`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `FormSubmission` (
    `id` VARCHAR(191) NOT NULL,
    `locationLat` DOUBLE NOT NULL,
    `locationLng` DOUBLE NOT NULL,
    `submittedAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `metadataId` VARCHAR(191) NULL,

    UNIQUE INDEX `FormSubmission_metadataId_key`(`metadataId`),
    INDEX `FormSubmission_submittedAt_idx`(`submittedAt`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `FormSubmissionSchedule` (
    `id` VARCHAR(191) NOT NULL,
    `formSubmissionId` VARCHAR(191) NOT NULL,
    `dayOfWeek` ENUM('Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado') NOT NULL,
    `entryTime` VARCHAR(191) NOT NULL,
    `exitTime` VARCHAR(191) NOT NULL,

    INDEX `FormSubmissionSchedule_formSubmissionId_idx`(`formSubmissionId`),
    UNIQUE INDEX `FormSubmissionSchedule_formSubmissionId_dayOfWeek_key`(`formSubmissionId`, `dayOfWeek`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- AddForeignKey
ALTER TABLE `AccountRole` ADD CONSTRAINT `AccountRole_metadataId_fkey` FOREIGN KEY (`metadataId`) REFERENCES `Metadata`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Account` ADD CONSTRAINT `Account_roleId_fkey` FOREIGN KEY (`roleId`) REFERENCES `AccountRole`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Account` ADD CONSTRAINT `Account_metadataId_fkey` FOREIGN KEY (`metadataId`) REFERENCES `Metadata`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Metadata` ADD CONSTRAINT `Metadata_createdById_fkey` FOREIGN KEY (`createdById`) REFERENCES `Account`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Metadata` ADD CONSTRAINT `Metadata_updatedById_fkey` FOREIGN KEY (`updatedById`) REFERENCES `Account`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Metadata` ADD CONSTRAINT `Metadata_deletedById_fkey` FOREIGN KEY (`deletedById`) REFERENCES `Account`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `MetadataUpdateHistory` ADD CONSTRAINT `MetadataUpdateHistory_metadataId_fkey` FOREIGN KEY (`metadataId`) REFERENCES `Metadata`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `MetadataUpdateHistory` ADD CONSTRAINT `MetadataUpdateHistory_updatedById_fkey` FOREIGN KEY (`updatedById`) REFERENCES `Account`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Config` ADD CONSTRAINT `Config_metadataId_fkey` FOREIGN KEY (`metadataId`) REFERENCES `Metadata`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `FormSubmission` ADD CONSTRAINT `FormSubmission_metadataId_fkey` FOREIGN KEY (`metadataId`) REFERENCES `Metadata`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `FormSubmissionSchedule` ADD CONSTRAINT `FormSubmissionSchedule_formSubmissionId_fkey` FOREIGN KEY (`formSubmissionId`) REFERENCES `FormSubmission`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
