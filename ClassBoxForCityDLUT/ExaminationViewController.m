//
//  ExaminationViewController.m
//  ClassBoxForCityDLUT
//
//  Created by 胡啸晨 on 15/5/29.
//  Copyright (c) 2015年 com.DavidHu. All rights reserved.
//

#import "ExaminationViewController.h"
#import "ExaminationViewCell.h"
#import "ExaminationFetcher.h"
#import "Student.h"
#import <MagicalRecord/MagicalRecord.h>

static NSString *CellIdentifier = @"cell";

@interface ExaminationViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation ExaminationViewController

- (void)setGrades:(NSArray *)grades{
    _grades = grades;
    
    if (self.spinner.isAnimating) {
        [self.spinner stopAnimating];
    }
    
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.navigationController.navigationBarHidden = NO;
    [self.spinner startAnimating];
    
    [self fetchExamination];
    if (self.tableView == nil) {
        [self createTableView];
    }
}

- (void)fetchExamination{
    NSArray *student = [Student MR_findAll];
    NSString *studentName = [student[0] valueForKeyPath:@"username"];
    NSString *password = [student[0] valueForKeyPath:@"password"];
    NSInteger startItem = [[studentName substringToIndex:4] intValue];

    ExaminationPagerViewController *pager;
    NSInteger itemOnTab = [pager.itemOnTab integerValue];
    NSLog(@"item value: %ld", itemOnTab);
    
    NSInteger term = 5 + (startItem - 2010) * 2 + itemOnTab;
    
    NSURL *url = [ExaminationFetcher URLforExamination:studentName password:password term:term];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (!connectionError) {
                                   if (response.URL == url) {
                                       NSDictionary *returnStatus = [NSJSONSerialization JSONObjectWithData:data
                                                                                                    options:0
                                                                                                      error:&connectionError];
                                       NSArray *grade = [returnStatus valueForKey:INFO];
                                       NSLog(@"grade: %@", grade);
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           self.grades = grade;
                                       });
                                  }
                               }
                           }];
}

- (void)createTableView{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[ExaminationViewCell class] forCellReuseIdentifier:CellIdentifier];
    
    [self.view addSubview:self.tableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ExaminationViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *grade = self.grades[indexPath.row];
    cell.name.text = [grade valueForKeyPath:NAME];
    cell.category.text = [grade valueForKeyPath:CATEGORY];
    cell.examining_method.text = [grade valueForKeyPath:EXAMINING_METHOD];
    cell.credit_hours.text = [grade valueForKeyPath:CREDIT_HOURS];
    cell.credit.text = [grade valueForKeyPath:CREDIT];
    cell.average_gradesTitle.text = @"平时成绩";
    cell.final_gradesTitle.text = @"期末成绩";
    cell.general_gradesTitle.text = @"综合成绩";
    cell.average_grades.text = [grade valueForKeyPath:AVERAGE_GRADES];
    cell.final_grades.text = [grade valueForKeyPath:FINAL_GRADES];
    cell.general_grades.text = [grade valueForKeyPath:GENERAL_GRADES];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.grades count];
}

#pragma mark - fetchResult


#pragma mark - mem warn
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
