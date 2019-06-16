## 跨库连接数据库：两种方法
* 完整模式

`select * from ecology.dbo.hrmresource`

* 省略dbo 

`select * from ecology..hrmresource`

## 跨服务器连接数据库
#### 在sql可视化工具中服务器对象-链接服务器中创建查看或代码创建

1. 创建链接服务器
```
exec sp_addlinkedserver   'NKYM', '', 'SQLOLEDB', '10.1.0.66'   
exec sp_addlinkedsrvlogin 'NKYM', 'false',null, 'sql', 'sql2008' 
```  
2. 查询示例

`select * from NKYM.ecology.dbo.hrmresource`

3. 删除链接服务器

`exec sp_dropserver 'NKYM', 'droplogins'`

## 连接远程/局域网数据(openrowset/openquery/opendatasource) 

``` 
select * from openrowset( 'SQLOLEDB', 'sql服务器名'; '用户名'; '密码',数据库名.dbo.表名)

```