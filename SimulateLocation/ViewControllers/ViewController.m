//
//  ViewController.m
//  SimulateLocation
//
//  Created by wyh on 2021/2/14.
//

#import "ViewController.h"
#import "TDSelectMapView.h"
#import "TDLocationSelectViewController.h"
#import "TDLocationConverter.h"

@interface ViewController () <TDSelectMapViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) TDSelectMapView *mapView;

@property (nonatomic, copy) NSString *searchResult;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self configUI];
}

#pragma mark - Methods

- (void)mapViewSelectCoordinate:(CLLocationCoordinate2D)coordinate locationName:(NSString *)locationName animated:(BOOL)animated {
    _searchResult = locationName;
    _mapView.currentAnnotation.coordinate = coordinate;
    _mapView.currentAnnotation.title = locationName;
    [_mapView Map_selectAnnotation:_mapView.currentAnnotation animated:animated];
    [_mapView Map_addOverLayFromAnnotation:_mapView.currentAnnotation];
    [_tableView reloadData];
}

#pragma mark - UI

- (void)configUI {
    
    self.navigationItem.title = @"🌍";
    
    _tableView = ({
        UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectZero style:(UITableViewStyleGrouped)];
        tableView.delegate = self;
        tableView.dataSource = self;
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuide);
            make.left.right.bottom.equalTo(self.view);
        }];
        tableView;
    });
    
    _mapView = ({
        TDSelectMapView *mapView = [[TDSelectMapView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 375) annotation:nil delegate:self];
        mapView;
    });
    
    _tableView.tableFooterView = _mapView;
}

#pragma mark - TableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    else {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleValue1)
                                     reuseIdentifier:@"cell"];
    }
    switch (indexPath.section) {
        case 0:
        {
            cell.textLabel.textColor = UIColor.systemBlueColor;
            cell.textLabel.text = _searchResult;
        }
            break;
        case 1:
        {
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Latitude";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.4f",_coordinate.latitude];
            }
            else if (indexPath.row == 1) {
                cell.textLabel.text = @"Longitude";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.4f",_coordinate.longitude];
            }
        }
            break;
        default:
            break;
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = nil;
    switch (section) {
        case 0:
            title = @"Search Location";
            break;
        case 1:
            title = @"Current WGS Coordinate";
            break;
        default:
            break;
    }
    return title;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 10.f;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        @weakify(self);
        TDLocationSelectViewController *locationSelVC = [[TDLocationSelectViewController alloc]initWithLocationText:_mapView.currentAnnotation.title selecrResult:^(NSString *locationName, CLLocationCoordinate2D coordinate) {
            CLLocationCoordinate2D wgsCoordinate = [TDLocationConverter transformFromGCJToWGS:coordinate];
            [self_weak_ mapViewSelectCoordinate:wgsCoordinate locationName:locationName animated:NO];
        }];
        UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:locationSelVC];
        [self.navigationController presentViewController:naviVC animated:YES completion:^{
            
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

#pragma mark - TDSelectMapViewDelegate

- (void)mapView:(TDSelectMapView *)mapView didUpdateCurrentLocation:(NSString *)location coordinate:(CLLocationCoordinate2D)coordinate {
    _searchResult = location;
    CLLocationCoordinate2D wgsCoordinate = [TDLocationConverter transformFromGCJToWGS:coordinate];
    _coordinate = wgsCoordinate;
    [_tableView reloadData];
}

@end
