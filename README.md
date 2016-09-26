# PandaDBSwift简述
PandaDBSwift基于Swift3的开源数据库框架，它的主要特点为：

1. 基于Swift3语法，支持IOS 8.0以上
2. 同步的数据库操作
3. 倡导SQLite及原生SQL编写
4. 封装了表的创建及升级
5. 支持自由事务嵌套行为，简化对数据库事务的操作


> 为什么是同步的数据库操作

我们都知道，网上大多数据库及网络框架都是提供异步，当然数据库或网络也应该在非主线程上完成，那为什么笔者提供的数据库以及Http网络框架([PandaHttpSwift](https://github.com/lingen/PandaHttpSwift))都是同步性的呢

>笔者移动端的一个最重要的开发规范是: 
>> 服务层异步，数据库&网络层同步，请参阅[御剑的IOS开源编码规范](http://ios-guildline.lingenliu.com/)以了解更多详情  (Swift版要在笔者完成至少一个APP后才提供，以验证可行性)

## 如何在项目中引用它

> cocoapods

~~~
 框架还未有效在APP中使用，不提供此引用方式
~~~

> framework依赖

~~~
 请下载源码，使用Xcode编译，可以得到PandaDbSwift.framework，请在项目中加入依赖以使用
~~~

## 数据库及表的定义
>如何一个数据库对象

~~~

        let table =  TableHelper
            .createInstance(tableName: "users")
            .textColumn(name: "name")
            .intColumn(name: "age")
            .realColumn(name: "weight")
            .blobColumn(name: "data")
            .build()!
        
        let createTableSQL = table.createTableSQL()
        
~~~ 

> 定义一个数据库

~~~
        
        //定义表
        var tables:Array<(Void)->Table> = [];
        
        tables.append { (Void) -> Table in
            
            let table =  TableHelper
                .createInstance(tableName: "user_3")
                .textColumn(name: "name")
                .intColumn(name: "age")
                .realColumn(name: "weight")
                .blobColumn(name: "data")
                .build()!
            
            return table;
        }
        
                //定义升级block
        let updateBlock = { (from:Int,to:Int) -> String in
            
            if from == 1 && to == 2 {
                //返回1到2的数据库升级语句
                return "";
            }
            else if from == 2 && to == 3 {
                //返回2到3的数据库升级语句
                return "";
            }
            
            return "";
        }
        
         //定义数据库repository
        let repository = Repository.createRepository(dbName: "abc.sqlite", tables: tables, version: 1, updateBlock:updateBlock)
~~~

按照如上定义，repository就是数据库对象，你可以使用它进行数据库操作了,

> abc.sqlite将会在APP的Document目录下自行创建（如果不存在的话）


## 数据库API

### 更新API
> 更新SQL，不带参数

~~~swift
//传入一个SQL字符，返回执行结果 是否正确
func executeUpdate(sql:String) -> Bool

//传入一条带命名参数的SQL语句，返回执行是否成功
func executeUpdate(sql:String,params:Dictionary<String,Any>?) -> Bool

~~~

>>示例代码;

~~~swift
//不带命名参数
var succss = repository.executeUpdate(sql: "delete from users") 
print("清除表:\(succss)")  

//带命名参数
let insertTableSQL = "insert into users (name,age,weight,info) values (:name,:age,:weight,:info)"
let params:Dictionary<String,Any>? = ["age":30,"name":"御剑","weight":150.00,"info":Data(bytes: Array("更多个人信息".utf8))]
succss = repository.executeUpdate(sql: insertTableSQL, params: params)
~~~

### 查询API
> 执行查询SQL，不带参数

~~~swift
//执行一条查询SQL，不带命名参数，返回数组
func executeQuery(sql:String) -> Array<Dictionary<String,Any>>?

//执行一条查询SQL，带命名参数，返回数组
func executeQuery(sql:String,params:Dictionary<String,Any>?) -> Array<Dictionary<String,Any>>?

//执行一条查询SQL，不带命名参数，期望只返回一条数据
func executeSingleQuery(sql:String) -> Dictionary<String,Any>?

//执行一条查询SQL,带命名参数，期望只返回一条数据
func executeSingleQuery(sql:String,params:Dictionary<String,Any>?) -> Dictionary<String,Any>?


~~~

>> 示例代码

~~~swift
//不带命名参数
let results = repository.executeQuery(sql: "select * from users")
  print("查询结果:\(results)")

//带命名参数的查询 
let results = repository.executeQuery(sql: "select * from users where user = :user",params: ["name":"AAA"])

print("查询结果:\(results)")
~~~

> 

### 表是否存在API

~~~
//传入一个表名，返回表是否存在
func tableExists(tableName:String) -> Bool
~~~

## 自由事务API

~~~
//这个API可以把多个数据库操作嵌入一个事务
func executeInTransaction(dbBlock:(Void) -> Void) 
~~~

>示例代码:

~~~swift
//定义一个大数据量写行为
        let batchInsert:((Void)->Void) = { (Void) -> Void in
            for index in 0...5000 {
                let insertTableSQL = "insert into users (name,age,weight,info) values (:name,:age,:weight,:info)"
                let params:Dictionary<String,Any> = ["age":index,"name":"AAA\(index)","weight":10.00,"info":Data(bytes: Array("ABC\(index)".utf8))]
                let success = repository.executeUpdate(sql: insertTableSQL, params: params)
                print("插入表数据 :\(success)")
            }
        }
        
        //自由事务，这一层开启事务
        repository.executeInTransaction {
            batchInsert()
            
            repository.executeInTransaction {
                batchInsert()
            }
        }

~~~

PandaDbSwift一个重要的特性就是事务自识别，你可以使用executeInTransaction来包含一系列的数据库操作，在executeInTransaction包含范围内的都属于一个事务

如果没有executeInTransaction，那executeUpdate等更新API会自动生成一个事务

## 错误SQL自动日志记录机制
对于打包模式下，错误的SQL会自动在用户主目录下存储并记录，开发人员可以随时查看此日志以找到错误的SQL日志

>这个机制还未实现，待完善中

## 主线程自动检测机制
此框架是一个同步数据库操作框架，很容易一不小心会出现在主线程上执行SQL等，这是不允许的，因此框架自行检测这个特性，如果在主线程执行SQL操作，APP就会崩盘

> 这个机制还未实现，待完善中

## 只支持命名查询SQL
通常，SQL中带参数，有两种写法
> ? 方式

~~~sql
select * from user where name = ?
~~~

> 命名查询方式

~~~
select * from user where name = :name
~~~

PandaDbSwift只支持命名查询方式

> 为什么要这样
>> 笔者的框架有一个重要理念：只提供更少的选择
>> 
>> 上述两种方式都可以，但笔者希望APP只使用某一种方式，以保证APP风格的统一；
