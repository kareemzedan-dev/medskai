import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/mobx-store/wishlist_store.dart';
import 'package:flutter_app/app/backend/models/cate-model.dart';
import 'package:flutter_app/app/backend/models/course_model.dart';
import 'package:flutter_app/app/backend/parse/courses_parse.dart';
import 'package:flutter_app/app/helper/router.dart';
import '../view/components/course_sort_dropdown.dart';
import '../view/components/view_mode_toggle.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_app/app/core/error/app_error.dart';
import 'package:flutter_app/app/core/error/error_handler.dart';
import 'package:flutter_app/app/util/toast.dart';

class CoursesController extends GetxController implements GetxService {
  final CoursesParser parser;

  final List<CourseModel> _courses = <CourseModel>[].obs;

  List<CourseModel> get coursesList => _courses;
  List<CategoryModel> _categoriesList = <CategoryModel>[];

  List<CategoryModel> get cateList => _categoriesList;
  late ScrollController scrollController;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool isInitialLoading = true;
  bool isLoadingCategories = true;
  bool hasError = false;
  String errorMessage = '';
  AppError? appError;
  int _page = 1;
  final int _pageSize = 50;
  String search = '';
  List<int> _cateIds = [];

  List<int> get cateIds => _cateIds;
  List<dynamic> _list=[];
  List<dynamic> get list => _list;
  String _dropdownValue='';

  String get dropdownValue => _dropdownValue;

  CourseSortOption sortOption = CourseSortOption.newest;
  CategoryModel? selectedCategory;
  ViewMode viewMode = ViewMode.grid;
  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  // Price filter: 'free', 'paid', or null (all)
  String? priceFilter;

  // Rating filter: minimum rating threshold, null means no filter
  double? minRating;

  Timer? _debounceTimer;

  CoursesController({required this.parser});

  void refreshScreen() {
    update();
  }

  void setKeywordSearch(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      search = value;
      refreshData();
    });
  }

  Future<void> onSetCateId(int id) async {
    _cateIds = [id];
    refreshData();
  }

  Future<void> onFilterValue(String v) async {
    _dropdownValue = v;
    refreshData();
  }

  @override
  void onInit() {
    super.onInit();
    getCategory();
    getData();
    handleGetOption();
    loadCategories();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
  }
  handleGetOption(){
    _list = [
      {
        "key":"Default",
        "index":0,
        "label":tr(LocaleKeys.courses_filters_default)
      },
      {
        "key":"Title",
        "index":1,
        "label":tr(LocaleKeys.courses_filters_title)
      },
      {
        "key":"Newest",
        "index":2,
        "label":tr(LocaleKeys.courses_filters_newest)
      },
      {
        "key":"Oldest",
        "index":3,
        "label":tr(LocaleKeys.courses_filters_oldest)
      },
      {
        "key":"Sale",
        "index":4,
        "label":tr(LocaleKeys.courses_filters_sale)
      },
      {
        "key":"Popular",
        "index":5,
        "label":tr(LocaleKeys.courses_filters_popular)
      }
    ];
    _dropdownValue = list.isNotEmpty ? list.first['key'] : 'Default';
    update();
    refresh();
  }

  void changeSortOption(CourseSortOption option) {
    sortOption = option;
    _courses.clear();
    _page = 1;
    update();
    loadCourses();
  }

  void changeCategory(CategoryModel? category) {
    selectedCategory = category;
    _courses.clear();
    _page = 1;
    update();
    loadCourses();
  }

  void changeViewMode(ViewMode mode) {
    viewMode = mode;
    update();
  }

  void setPriceFilter(String? value) {
    priceFilter = value;
    refreshData();
  }

  void setRatingFilter(double? value) {
    minRating = value;
    refreshData();
  }

  void clearAllFilters() {
    search = '';
    _cateIds = [];
    selectedCategory = null;
    priceFilter = null;
    minRating = null;
    refreshData();
  }

  /// Returns the number of currently active advanced filters (price, rating, category).
  int get activeFilterCount {
    int count = 0;
    if (priceFilter != null) count++;
    if (minRating != null) count++;
    if (_cateIds.isNotEmpty || selectedCategory != null) count++;
    return count;
  }

  Future<void> loadCategories() async {
    try {
      final response = await parser.getCategory();
      if (response.statusCode == 200 && response.body is List) {
        _categories = [];
        for (var data in response.body) {
          _categories.add(CategoryModel.fromJson(data));
        }
        update();
      }
    } catch (e) {
      debugPrint('loadCategories error: $e');
    }
  }

  Future<void> loadCourses() async {
    await getData();
  }

  Future<void> onSearch() async {
    Get.toNamed(AppRouter.getSearchCourseRoute(), arguments: [search]);
  }

  Future<void> getCategory() async {
    isLoadingCategories = true;
    update();
    try {
      Response response = await parser.getCategory();
      if (response.statusCode == 200) {
        _categoriesList = [];
        final body = response.body;
        if (body != null && body is List) {
          body.forEach((data) {
            CategoryModel cateData = CategoryModel.fromJson(data);
            _categoriesList.add(cateData);
          });
        }
      }
    } catch (e) {
      debugPrint('getCategory error: $e');
    } finally {
      isLoadingCategories = false;
      update();
    }
  }

  bool _isRefreshing = false;

  Future<void> refreshData() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    _page = 1;
    hasError = false;
    errorMessage = '';
    appError = null;
    isLoadingMore = true;
    _courses.clear();
    await getData();
    _isRefreshing = false;
  }

  void retryLoadData() {
    hasError = false;
    errorMessage = '';
    appError = null;
    isInitialLoading = true;
    update();
    getData();
  }

  Future<void> onFilter(int id) async {
    if (_cateIds.contains(id)) {
      _cateIds = _cateIds.where((element) => element != id).toList();
    } else {
      _cateIds.add(id);
    }
    refreshData();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (isLoadingMore || isLoading || _isRefreshing) return;
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    _page = _page + 1;
    getData();
  }

  // function to fetch courses from API
  Future<void> getData() async {
    if (!isLoading) {
      isLoading = true;
      Map<String, String> params = {
        'page': '$_page',
        'per_page': '${_pageSize}',
        ...CourseSortDropdown.getApiParams(sortOption),
      };
      if (selectedCategory != null) {
        params['category'] = selectedCategory!.id.toString();
      }
      // Also include legacy category filter if set
      if (_cateIds.isNotEmpty && !params.containsKey('category')) {
        params['category'] = _cateIds.join(',');
      }
      var body = {
        ...params,
      };
      if (search != "") {
        body = {
          ...body,
          "search": search,
        };
      }
      var itemElement = list.firstWhereOrNull((element) => element['key'] == _dropdownValue);
    int? index = 0;
    if(itemElement != null){
      index = itemElement['index'];
    }
      if (index == 4) {
        body = {
          ...body,
          "on_sale": "true",
        };
      }
      if (index == 5) {
        body = {
          ...body,
          "popular": "true",
        };
      }
      if (index == 1) {
        body = {...body, "orderby": "title", "order": "asc"};
      }
      if (index == 2) {
        body = {...body, "orderby": "date", "order": "desc"};
      }
      if (index == 3) {
        body = {...body, "orderby": "date", "order": "asc"};
      }

      try {

        final response = await parser.getCourses(body);
        if (response.statusCode == 200) {
          List<CourseModel> lstTemp = [];
          final body = response.body;
          if (body != null && body is List) {
            body.forEach((data) {
              CourseModel course = CourseModel.fromJson(data);
              lstTemp.add(course);
            });
          }
          // Apply client-side price filter
          if (priceFilter == 'free') {
            lstTemp.removeWhere((c) => c.price != null && c.price != 0);
          } else if (priceFilter == 'paid') {
            lstTemp.removeWhere((c) => c.price == null || c.price == 0);
          }
          // Apply client-side rating filter
          if (minRating != null) {
            lstTemp.removeWhere((c) => (c.rating ?? 0) < minRating!);
          }
          if (lstTemp.length < _pageSize) {
            isLoadingMore = false;
          }
          _courses.addAll(lstTemp);
        } else if (response.statusCode == 401) {
          showToast(tr(LocaleKeys.errors_auth_sessionExpired), isError: true);
          Get.offAllNamed(AppRouter.getLoginRoute());
          return;
        } else {
          hasError = true;
          errorMessage = response.statusText ?? tr(LocaleKeys.errorMessages_loadCourses);
        }
      } catch (e) {
        appError = ErrorHandler.fromException(e);
        hasError = true;
        errorMessage = appError!.title;
        debugPrint('getCourses error: $e');
      } finally {
        isLoading = false;
        isInitialLoading = false;
        if (!isClosed) update();
      }
    }
  }

  Future<void> onToggleWishlist(CourseModel item) async {
    final context = Get.context;
    if (context == null) return;
    if (parser.getToken() == "") {
      Alert(
        context: context,
        title: tr(LocaleKeys.alert_notLoggedIn),
        desc: tr(LocaleKeys.alert_loggedIn),
        buttons: [
          DialogButton(
            color: MedsKaiColors.error,
            child: Text(tr(LocaleKeys.alert_cancel),
                style: TextStyle(color: MedsKaiColors.white)),
            onPressed: () => Navigator.pop(context),
          ),
          DialogButton(
            child: Text(tr(LocaleKeys.alert_btnLogin),
                style: TextStyle(color: MedsKaiColors.white)),
            onPressed: () {
              Navigator.pop(context);
              Get.offAllNamed(AppRouter.getLoginRoute());
            },
          ),
        ],
      ).show();
      return;
    }
    final WishlistStore wishlistStore = Get.find<WishlistStore>();
    final success = await wishlistStore.optimisticToggle(item);
    if (!success) {
      showToast(tr(LocaleKeys.errorMessages_loadWishlist), isError: true);
    }
    update();
  }

  Future<void> launchInBrowser(String link) async {
    try {
      final url = Uri.parse(link);
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('launchInBrowser error: $e');
    }
  }
}
