//
//  TDLocationSelectViewController.m
//  ToDo
//
//  Created by wyh on 2019/11/23.
//  Copyright © 2019 wyh. All rights reserved.
//

#import "TDLocationSelectViewController.h"
#import "TDLocationResultCell.h"

#import <MapKit/MapKit.h>

#import "TDLocationService.h"

static NSString * const TDLocationSelectTableViewCellReuseId = @"TDLocationSelectTableViewCellReuseId";

@interface TDCurrentLocationTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *icon;

@property (nonatomic, strong) UIActivityIndicatorView *hud;

@end

@implementation TDCurrentLocationTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    
    TDCurrentLocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TDLocationSelectTableViewCellReuseId];
    if (!cell) {
        cell = [[TDCurrentLocationTableViewCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:TDLocationSelectTableViewCellReuseId];
    }
    [cell configUI];
    return cell;
}

- (void)startLoading {
    [_hud startAnimating];
    _icon.hidden = YES;
}

- (void)stopLoading {
    [_hud stopAnimating];
    _icon.hidden = NO;
}

- (void)configUI {
    
    _icon = ({
        UIImageView *icon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_cell_my_location"]];
        [self addSubview:icon];
        [icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(15.f);
            make.centerY.equalTo(self.mas_centerY);
        }];
        icon;
    });
    
    _hud = ({
        UIActivityIndicatorView *hud = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
        hud.hidesWhenStopped = YES;
        [self addSubview:hud];
        [hud mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_icon.mas_centerX);
            make.centerY.equalTo(_icon.mas_centerY);
        }];
        hud;
    });
    
    UILabel *titleLabel = ({
        titleLabel = [[UILabel alloc]init];
        titleLabel.text = @"当前位置";
        titleLabel.font = [UIFont boldSystemFontOfSize:18.f];
        titleLabel.textColor = UIColor.systemBlueColor;
        [self addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_icon.mas_right).offset(15.f);
            make.centerY.equalTo(self.mas_centerY);
        }];
        titleLabel;
    });
}

@end

@interface TDLocationSelectViewController () <UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,TDLocationServiceDelegate>

@property (nonatomic, strong) NSMutableArray<MKMapItem*> *searchResultArray;
@property (nonatomic, strong) NSMutableArray<MKLocalSearch*> *searchSessions;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, copy) TDSelectResultClosure resultHandler;

@end

@implementation TDLocationSelectViewController
{
    NSString * _userLocationName;
    CLLocationCoordinate2D _userCoordinate;
    NSString * _origionLocationName;
}

- (void)dealloc {
    [TDLocationService removeMonitorLocationServiceFromHandler:self];
}

- (instancetype)initWithLocationText:(NSString *)location selecrResult:(TDSelectResultClosure)result {
    
    if (self = [super init]) {
        _origionLocationName = location;
        _resultHandler = result;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initialize];
    
    [self configNavBar];
    
    [self configUI];
    
    if (!CLLocationCoordinate2DIsValid(_userCoordinate)) {
        TDCurrentLocationTableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [cell startLoading];
    }
}

#pragma mark - Initialize

- (void)initialize {
    
    _searchResultArray = [NSMutableArray new];
    _searchSessions = [NSMutableArray new];
    
    [TDLocationService registMonitorLocaitonServiceWithHandler:self];
    [TDLocationService startMonitorUserLocation];
    
    _userCoordinate = TDLocationService.sharedLocationService.userLocation.coordinate;
    [TDLocationService reverseGeocodeLocationWithCoordinate:_userCoordinate
                                          preferredLanguage:(TDLocationLocaleLanguageEN)
                                            completeHandler:^(CLPlacemark *mark, NSError *error) {
        self->_userLocationName = mark.name;
    }];
}

#pragma mark - Event Methods

- (void)nav_cancel:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Operation

- (void)searchLocationWithQueryText:(NSString *)query
                  completionHandler:(void(^)(NSArray <MKMapItem *> *results))completionHandler {
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc]init];
    request.naturalLanguageQuery = query;
    
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [self.searchSessions addObject:search];
    
    @weakify(self);
    [search startWithCompletionHandler:^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (response.mapItems.count == 0) {
                NSLog(@"Location not found.");
            }
            if(completionHandler) completionHandler(response.mapItems);
            [self_weak_.searchSessions removeObject:search];
        });
    }];
}

#pragma mark - TDLocationServiceDelegate

- (void)TDLocationService:(TDLocationService *)service didUpdateLocation:(CLLocation *)location {
    
    _userCoordinate = location.coordinate;
    
    [TDLocationService reverseGeocodeLocationWithCoordinate:_userCoordinate
                                          preferredLanguage:(TDLocationLocaleLanguageEN)
                                            completeHandler:^(CLPlacemark *placemark, NSError *error) {
        TDCurrentLocationTableViewCell *cell = [self->_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [cell stopLoading];
        self->_userLocationName = placemark.name;
    }];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length == 0) {
           
           // Cancel all tasks.
           if (_searchSessions.count > 0) {
               [_searchSessions enumerateObjectsUsingBlock:^(MKLocalSearch * _Nonnull search, NSUInteger idx, BOOL * _Nonnull stop) {
                   [search cancel];
               }];
           }
           [_searchResultArray removeAllObjects];
           [_tableView reloadData];
            return;
    }
    @weakify(self);
    [self searchLocationWithQueryText:searchText completionHandler:^(NSArray<MKMapItem *> *results) {
        
        [self_weak_.searchResultArray removeAllObjects];
        if (results.count > 0) {
            [self_weak_.searchResultArray addObjectsFromArray:results];
        }
        
        [self_weak_.tableView reloadData];
    }];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
}


#pragma mark - TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return _searchResultArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *o_cell;
    if (indexPath.section == 0) {
        TDCurrentLocationTableViewCell *cell = [TDCurrentLocationTableViewCell cellWithTableView:tableView];
        o_cell = cell;
    }else {
        TDLocationResultCell *cell = [TDLocationResultCell locationCellWithTableView:tableView];
        MKMapItem *item = _searchResultArray[indexPath.row];
        [cell reloadData:^(UILabel *titleLabel, UILabel *descLabel) {
            titleLabel.text = item.placemark.name;
            descLabel.text = item.placemark.locality;
        }];
        o_cell = cell;
    }
    return o_cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    NSString *locationName ;
    if (indexPath.section == 0) {
        if (!CLLocationCoordinate2DIsValid(_userCoordinate)) {
            return;
        }
        CLLocationCoordinate2D WGScoordinate = _userCoordinate;
        locationName = _userLocationName;
        CLLocationCoordinate2D GCJcoordinate = [TDLocationConverter transformFromWGSToGCJ:WGScoordinate];
        // call back
        if (_resultHandler) {
            _resultHandler(locationName ,GCJcoordinate);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }else {
        MKMapItem *mapItem = _searchResultArray[indexPath.row];
        CLLocationCoordinate2D GCJcoordinate = mapItem.placemark.coordinate;
        locationName = mapItem.placemark.name;
//        CLLocationCoordinate2D WGSCoordinate = [TDLocationConverter transformFromGCJToWGS:GCJcoordinate];
        
        
        // call back
        if (_resultHandler) {
            _resultHandler(locationName ,GCJcoordinate);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        if (_searchResultArray.count > 0) {
            return @"当前位置";
        }
    }
    return nil;
}

#pragma mark - UI

- (void)configNavBar {
    
    self.navigationItem.title = @"位置选择";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:(UIBarButtonSystemItemCancel) target:self action:@selector(nav_cancel:)];
    self.navigationItem.rightBarButtonItem.tintColor = UIColor.systemBlueColor;
}

- (void)configUI {
    
    _searchBar = ({
        UISearchBar *bar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds) - 20.f, 48.f)];
        bar.placeholder = @"请输入位置";
        bar.text = _origionLocationName;
        bar.delegate = self;
//        bar.translucent = YES ;
//        UITextField *searchField = [bar valueForKey:@"_searchField"];
//        if (searchField != nil) {
//            [searchField setFont:[UIFont systemFontOfSize:15.f]];
//            [searchField setValue:Color_Dark_Grey forKeyPath:@"_placeholderLabel.textColor"];
//        }
        bar.backgroundImage = [UIImage new];
        bar.barTintColor = UIColor.systemBlueColor;
        [self.view addSubview:bar];
        [bar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuide).offset(15.f);
            make.left.equalTo(self.view.mas_left).offset(18.f);
            make.right.equalTo(self.view.mas_right).offset(-18.f);
            make.height.offset(48.f);
        }];
        bar;
    });
    
    _tableView = ({
        UITableView *table = [[UITableView alloc]initWithFrame:CGRectZero style:(UITableViewStylePlain)];
        table.delegate = self;
        table.dataSource = self;
        [self.view addSubview:table];
        [table mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_searchBar.mas_bottom).offset(10.f);
            make.left.right.bottom.equalTo(self.view);
        }];
        table;
    });
    self.view.backgroundColor = _tableView.backgroundColor;
    [_tableView reloadData];
}


@end
