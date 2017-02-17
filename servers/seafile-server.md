# seafile-server升级
seafile-server-6.0.1版本频繁出现seafile服务挂掉的情况，更严重的是会导致apache服务挂掉
```
2921279 [02/16/2017 06:21:04 PM] http-server.c(733): DB error when check repo existence.
2921280 [02/16/2017 06:22:46 PM] ../common/mq-mgr.c(54): [mq client] mq cilent is started
2921281 [02/16/2017 06:22:56 PM] ../common/mq-mgr.c(54): [mq client] mq cilent is started
2921282 [02/16/2017 06:23:49 PM] ../common/seaf-db.c(576): Error get next result from prep stmt: mysql_stmt_fetch failed: Commands out of sync; you can't run this command now.
2921283 [02/16/2017 06:23:56 PM] ../common/mq-mgr.c(54): [mq client] mq cilent is started
2921284 [02/16/2017 06:24:06 PM] ../common/mq-mgr.c(54): [mq client] mq cilent is started
2921285 [02/16/2017 06:25:14 PM] ../common/seaf-db.c(576): Error get next result from prep stmt: mysql_stmt_fetch failed: Commands out of sync; you can't run this command now.
2921286 [02/16/2017 06:52:15 PM] pipe error: Too many open files
2921287 [02/16/2017 06:57:03 PM] pipe error: Too many open files
```
根据论坛上的回答,在6.0.6版本应该已经修正；  
现在upgrade到6.0.８，运行
