
    Charlin出框架的目标：简单、易用、实用、高度封装、绝对解耦！

# CoreList
    大型列表MVC体系，强大的封装，Charlin精华倾情奉献！！！
<br />


#### 框架依赖：<br />
.CoreStatus<br />
.CoreArchive<br />
.MJExtension<br />
.CoreHttp<br />
.CoreRefresh<br />
.CoreViewNetWorkStausManager<br />




<br /><br />

####框架特性：<br />
>1.高度封装了列表的事个网络请求过程<br />
>2.封装了上拉下拉加载<br />
>3.创新使用配置模型的方式，让更多变成可能 <br />
>4.高度统一了tableView和collectionView两个列表加载的整个过程全部共享一套业务，如果修改了任何一个地方，两个同时改变<br />
>5.优秀的数据解析、错误处理、网络错误处理及信息指示集成<br />
>6.多线程全部完美考虑。<br />
>7.支持所有系统和屏幕！<br />

<br /><br />
####使用说明：<br />

>1本框架集成了没有缓存功能的TableView列表、CollectionView列表。<br />
 
>2本框架依赖以下框架：CoreArchive、MJExtension、CoreHttp、CoreRefresh、CoreViewNetWorkStausManager<br />
 
>3使用前，一定要清醒的认识到，父类控制器一个ViewController，他里面分别装有TableView和CollectionView，并非纯正的TableViewVC和CollectionViewVC,因为这样很难统一封装网络请求及上拉下拉加载业务。<br />



<br /><br />

####使用步骤：
 
 1.UITableViewMVC的集成：<br />
>1.控制器：  建立控制器，继承自CoreLTVC，建立LTConfigModel模型并传递。<br /><br />
>2.视图：    建立视图cell，继承自LTCell，重写+(instancetype)cellPrepare方法，创建cell（父类默认从同名Nib创建，也可自行使用代码创建，注意cell从nib创建，nib中需要指定和类名相同的rid。）。<br /><br />
>3.模型：    继承通用模型，继承自CoreListCommonModel：重写+(NSArray *)modelPrepare:方法，解析并返回列表的字典数组。<br /><br />
 
 2.UICollectionViewMVC的集成：<br />
>1.控制器：  建立控制器，继承自CoreLCVC，控制器内部建立UICollectionViewFlowLayout及LTConfigModel模型并传递。<br /><br />
>2.视图cell：建立cell，继承自LCCell，内部实现-(void)dataFill即可。（注意cell从nib创建，nib中需要指定和类名相同的rid。）<br /><br />
>3.模型：    建立模型，继承自CoreListCommonModel，重写+(NSArray *)modelPrepare:方法，解析并返回列表的字典数组。<br /><br />

<br /><br />
####使用示例：<br />
    
     Tableviewmvc的集成：
     
     
     //控制器：
    /**
     *  模型配置
     */
    -(void)config{
    
      LTConfigModel *configModel=[[LTConfigModel alloc] init];
      //url
      configModel.url=@"http://218.244.141.72:8080/carnet/driver.php?m=Driver&c=User&a=test_fy";
      //请求方式
      configModel.httpMethod=LTConfigModelHTTPMethodPOST;
      //模型类
      configModel.ModelClass=[ShopModel class];
      //cell类
      configModel.ViewForCellClass=[ShopListCell class];
      //标识
      configModel.lid=NSStringFromClass(self.class);
      //pageName
      configModel.pageName=@"p";
      //pageSizeName
      configModel.pageSizeName=@"pagesize";
      //起始页码
      configModel.pageStartValue=1222;
      //行高
      configModel.cellHeight=100.0f;
      
      //配置完毕
      self.configModel=configModel;
    
     }
     
     //模型;
     +(NSArray *)modelPrepare:(id)obj{
        NSArray *dA=obj[@"data"][@"data"];
        return dA;
    }
     
     
     //视图：
     /**
     *  cell的创建
     */
    +(instancetype)cellPrepare{
        return [super cellPrepare];
    }


    -(void)dataFill{
        
        //模型转换
        ShopModel *shopModel=(ShopModel *)self.model;
        
        _indexLabel.text=[NSString stringWithFormat:@"%i",shopModel.mid];
        
        _titleLabel.text=shopModel.title;
        
        _descLabel.text=shopModel.content;
    }
     
     
     
     
     
     
     CollectionMVC的集成：
     - (instancetype)init
    {
        
        UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
        
        layout.itemSize=CGSizeMake(100, 100);
        layout.minimumLineSpacing=10;
        layout.minimumInteritemSpacing=10;
        layout.sectionInset=UIEdgeInsetsMake(10, 10, 10, 10);
        
        
        
        //注册cell
        self = [super initWithCollectionViewLayout:layout];
        if (self) {
            
        }
        return self;
    }
    
    
    - (void)viewDidLoad {
        [super viewDidLoad];
        self.title=@"九宫格列表";
        [self.collectionView  registerNib:[UINib nibWithNibName:@"TGCell" bundle:nil] forCellWithReuseIdentifier:@"TGCell"];
        
        self.collectionView.backgroundColor=[UIColor whiteColor];
        
        //模型配置
        [self config];
    }
    
        /**
        *  模型配置
        */
    -(void)config{
        
        LTConfigModel *configModel=[[LTConfigModel alloc] init];
        //url
        configModel.url=@"http://218.244.141.72:8080/carnet/driver.php?m=Driver&c=User&a=test_fy";
        //请求方式
        configModel.httpMethod=LTConfigModelHTTPMethodPOST;
        //模型类
        configModel.ModelClass=[TGModel class];
        //cell类
        configModel.ViewForCellClass=[TGCell class];
        //标识
        configModel.lid=NSStringFromClass(self.class);
        //pageName
        configModel.pageName=@"p";
        //pageSizeName
        configModel.pageSizeName=@"pagesize";
        //起始页码
        configModel.pageStartValue=0;
        //行高
        configModel.cellHeight=100.0f;
        //每页数量
        configModel.pageSize=18;
        
        //配置完毕
        self.configModel=configModel;
        
    }

     
     //视图：
     -(void)dataFill{
        
        //模型转换
        TGModel *tgModel=(TGModel *)self.model;
        
        self.noLabel.text=[NSString stringWithFormat:@"%i",tgModel.mid];
        
        self.titleLabel.text=tgModel.title;
        
        self.descLabel.text=tgModel.content;
        
    }
     
     
     //模型
     +(NSArray *)modelPrepare:(id)obj{
        NSArray *dA=obj[@"data"][@"data"];
        return dA;
    }
     
     
     
<br /><br />


-----
    CoreList   大型列表MVC体系，强大的封装，Charlin精华倾情奉献！！！
-----

<br /><br />

#### 版权说明 RIGHTS <br />
作品说明：本框架由iOS开发攻城狮Charlin制作。<br />
作品时间： 2013.03.12 17:28<br />


#### 关于Chariln INTRODUCE <br />
作者简介：Charlin-四川成都华西都市报旗下华西都市网络有限公司技术部iOS工程师！<br /><br />


#### 联系方式 CONTACT <br />
Q    Q：1761904945（请注明缘由）<br />
Mail：1761904945@qq.com<br />
