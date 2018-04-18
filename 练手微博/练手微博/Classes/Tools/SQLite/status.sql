-- 创建微博数据表, IF NOT EXISTS这句话非常重要 --
-- 这个是注释的写法 --

CREATE TABLE IF NOT EXISTS "T_Status" (
    "statusId" INTEGER NOT NULL,
    "userId" INTEGER NOT NULL,
    "status" TEXT,
    "createTime" TEXT DEFAULT (datetime('now','localtime')),
PRIMARY KEY("statusId","userId")
);
