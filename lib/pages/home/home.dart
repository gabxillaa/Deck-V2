import 'package:deck/backend/models/task.dart';
import 'package:deck/pages/flashcard/view_deck.dart';
import 'package:deck/pages/misc/colors.dart';
import 'package:deck/pages/misc/widget_method.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../backend/auth/auth_service.dart';
import '../../backend/flashcard/flashcard_service.dart';
import '../../backend/models/deck.dart';
import '../../backend/models/newTask.dart';
import '../../backend/task/task_provider.dart';
import '../../backend/task/task_service.dart';
import '../flashcard/flashcard.dart';
import '../misc/custom widgets/tiles/home_deck_tile.dart';
import '../task/main_task.dart';
import '../misc/custom widgets/functions/if_collection_empty.dart';
import '../misc/custom widgets/tiles/home_task_tile.dart';
import '../task/view_task.dart';
import 'notification.dart';

class HomePage extends StatefulWidget {
  final Function(int) onNavigateToIndex;

  const HomePage({
    super.key,
    required this.onNavigateToIndex
  });


  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final AuthService _authService = AuthService();
  final FlashcardService _flashcardService = FlashcardService();
  late List<Deck> _decks = [];
  late List<Deck> _recoDecks = [];
  late User? _user;
  final TaskService _taskService = TaskService();
  List<NewTask> upcomingTasks = [];

  //Initial values
  String greeting = "";
  bool hasTakenARecentQuiz = true;
  bool hasUnreadNotif = true;
  int correct = 0;
  int total = 0;
  String score = "0/0";
  bool isRecentQuizPassed = true;

  DateTime selectedDay = DateTime.now();
  // void goToPage(int pageIndex) {
  //   setState(() {
  //     index = pageIndex;
  //   });
  // }

  @override
  void initState() {
    super.initState();
    _user = _authService.getCurrentUser();
    _initUserDecks(_user);
    _getTasks();
    _initGreeting();
    _initScore();//temporary
  }

  void _initUserDecks(User? user) async {
    if (user != null) {
      String userId = user.uid;
      String? firstName = _user?.displayName?.split(" ").first;
      String? lastName = _user?.displayName?.split(" ").last;
      String? firstNameAndLastName = '${firstName ?? "User"} ${lastName ?? ""}';
      List<Deck> decks = await _flashcardService
          .getDecksByUserIdNewestFirst(); // Call method to fetch decks
      var result = await _flashcardService.getDecks("RECOMMENDED_DECKS");
      List<Deck> recoDecks = result['decks'];

      setState(() {
        _decks = decks; // Update state with fetched decks
        _recoDecks = recoDecks;
      });
    }
  }

  void _getTasks() async {
    List <NewTask> retrievedTasks = await _taskService.fetchNearingDueTasks();
    setState(() {
      upcomingTasks = retrievedTasks;
    });
  }

  void _initGreeting() {
      _user?.reload();
      String? firstName = _user?.displayName?.split(" ").first ?? 'User';
    setState(() {
      greeting = "Hello, $firstName!";
    });
  }

  void _initScore() async{
    try {
      final result = await _flashcardService.getLatestQuizAttempt();
      final latestAttempt = result['latest_attempt'] as Map<String, dynamic>;
      final deckInfo = result['deck'] as Map<String, dynamic>;
      final int attemptScore = latestAttempt['score'] as int;
      final int totalQuestion = latestAttempt['total_questions'] as int;

      setState(() {
        correct = attemptScore;
        total = totalQuestion;
        score = "$correct/$total";
        if(correct >= (total/2)){
          isRecentQuizPassed = true;
        }else {
          isRecentQuizPassed = false;
        }
      });
    } catch (e) {
      print('Error fetching latest quiz attempt: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DeckColors.backgroundColor,
      body: SafeArea(
          top: true,
          bottom: false,
          left: true,
          right: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children:[
                  Image.asset(
                    'assets/images/Deck-Home-Header.png',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding:EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      //greeting section
                      children: [
                        AutoSizeText(
                          greeting,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            height:1,
                            fontFamily: 'Fraiche',
                            fontSize: 35,
                            color: DeckColors.primaryColor,
                          ),
                          maxLines: 2,
                          minFontSize: 20,
                        ),
                        const Text(
                            'Let\'s be productive today as well!',
                            style: TextStyle(
                              fontFamily: 'Nunito-SemiBold',
                              fontSize: 15,
                              color: DeckColors.primaryColor,
                            )
                        ),
                        // ad and quiz tiles
                        const SizedBox(height: 20),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: hasTakenARecentQuiz
                                    ? Container(
                                  padding: EdgeInsets.all(15),
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: DeckColors.white,
                                      border: Border.all(color: DeckColors.primaryColor, width: 3),
                                      image: DecorationImage(
                                      image: AssetImage( isRecentQuizPassed ? 'assets/images/Deck-Background2.png': 'assets/images/Deck-Background2.png'),
                                      fit: BoxFit.cover ,
                                      alignment: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: DeckColors.deepGray,
                                        blurRadius: 4,
                                        offset: Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const AutoSizeText(
                                        "You had a score of",
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        style: TextStyle(
                                          height:1,
                                          fontSize: 15,
                                          fontFamily: 'Nunito-SemiBold',
                                          color: DeckColors.primaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      AutoSizeText(
                                        score,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        style: TextStyle(
                                            height:1,
                                            fontSize: 35,
                                            fontFamily: 'Fraiche',
                                            color: isRecentQuizPassed ? DeckColors.accentColor : DeckColors.deckRed ,
                                            overflow: TextOverflow.ellipsis
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      const AutoSizeText(
                                        "on your previous quiz.",
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        style: TextStyle(
                                          height:1,
                                          fontSize: 15,
                                          fontFamily: 'Nunito-SemiBold',
                                          color: DeckColors.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ) :
                                Container(
                                  padding: EdgeInsets.all(15),
                                  height: 120,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: DeckColors.primaryColor, width: 3),
                                    image: const DecorationImage(
                                      image: AssetImage('assets/images/Deck-Background1.png'),
                                      fit: BoxFit.fitWidth,
                                      alignment: Alignment.bottomCenter,

                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: DeckColors.deepGray,
                                        blurRadius: 4,
                                        offset: Offset(1, 1),
                                      ),
                                    ],
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [DeckColors.accentColor, DeckColors.deepblue],
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Title Text
                                      const AutoSizeText(
                                        "Start Fresh: Create\nYour New Deck Now!",
                                        maxLines: 2,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          height:1,
                                          fontSize: 18,
                                          fontFamily: 'Fraiche',
                                          color: DeckColors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 10), // Space between text and button
                                      // Create Deck Button
                                      ElevatedButton(
                                        onPressed: () {
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: DeckColors.white,
                                          foregroundColor: DeckColors.primaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                        ),
                                        child: const AutoSizeText("Create Deck",
                                            maxLines:1,
                                            style: TextStyle(
                                                fontFamily: 'Nunito-SemiBold',
                                                fontSize: 15,
                                                color: DeckColors.primaryColor,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(15),
                                    height: 120,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: DeckColors.primaryColor, width: 3),
                                      image: const DecorationImage(
                                        image: AssetImage('assets/images/Deck-Background1.png'),
                                        fit: BoxFit.fitWidth,
                                        alignment: Alignment.bottomCenter,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: DeckColors.deepGray,
                                          blurRadius: 4,
                                          offset: Offset(1, 1),
                                        ),
                                      ],
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [DeckColors.deepgreen ,DeckColors.primaryColor, DeckColors.deepblue],
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const AutoSizeText(
                                          "Spark Your Interest\nwith Fun Quizzes!",
                                          maxLines:2,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            height:1,
                                            fontSize: 18,
                                            fontFamily: 'Fraiche',
                                            color: DeckColors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 5), // Space between text and button
                                        // Search for Decks Button
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              RouteGenerator.createRoute(FlashcardPage()),
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            backgroundColor: DeckColors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                          ),
                                          child: const AutoSizeText("Search for Decks",
                                              maxLines: 1,
                                              minFontSize:8,
                                              style: TextStyle(
                                                  fontFamily: 'Nunito-SemiBold',
                                                  fontSize: 15,
                                                  color: DeckColors.primaryColor,
                                                  fontWeight: FontWeight.bold)
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                              )
                            ]
                        ),
                        const SizedBox(height: 10),
                        //upcoming deadline section
                        const SizedBox(height: 10),
                        const Text(
                            'Upcoming Deadlines',
                            style: TextStyle(
                                fontFamily: 'Fraiche',
                                fontSize: 30,
                                color: DeckColors.primaryColor,
                                fontWeight: FontWeight.bold)
                        ),
                        const SizedBox(height: 10),
                        if(upcomingTasks.isEmpty)
                          const IfCollectionEmpty(
                            hasIcon: false,
                            hasBackground: true,
                            ifCollectionEmptyText: 'YIPEE! No upcoming deadlines! ',
                            ifCollectionEmptySubText:
                            'Get ahead now! Add tasks and stay sharp!',
                          )
                        else if(upcomingTasks.isNotEmpty) ...[
                          ...upcomingTasks.take(3).map((task) =>

                              Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: HomeTaskTile(
                                  //TODO change datas here
                                  folderName: task.folderSource!,
                                  taskName: task.title,// task.taskName
                                  deadline: task.endDate,
                                  onPressed: () {},
                                  priority: task.priority,//task.priority
                                ),
                              )
                          ),
                        if (upcomingTasks.length > 3)
                          SizedBox(
                              width: double.infinity,
                              child:TextButton(
                                // onPressed:(){},
                              onPressed: ()  =>  widget.onNavigateToIndex(1),
                              style: TextButton.styleFrom(
                                backgroundColor: DeckColors.softGray,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  // side: BorderSide(
                                  //     width: 2,
                                  //     color: DeckColors.primaryColor
                                  // ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                    horizontal: 5
                                ),
                              ),
                              child: const Text(
                                "See more",
                                style: TextStyle(
                                  fontFamily: 'Nunito-SemiBold',
                                  fontSize: 15,
                                  color: DeckColors.darkgreen,
                                ),
                              ),
                            )
                          ),
                        ],
                        const SizedBox(height: 10),
                        //recently accessed decks section
                        const Text(
                            'Continue Learning',
                            style: TextStyle(
                                fontFamily: 'Fraiche',
                                fontSize: 30,
                                color: DeckColors.primaryColor,
                                fontWeight: FontWeight.bold)
                        ),
                        if (_decks.isEmpty)
                          const IfCollectionEmpty(
                            hasIcon: false,
                            hasBackground: true,
                            ifCollectionEmptyText: 'No Recent Decks Yet!',
                            ifCollectionEmptySubText:
                            'Discover new decks or create your own to learn.',
                          ),
                      ],
                    ),
                  ),

                  if (_decks.isNotEmpty)
                  SizedBox(
                    height: 150.0,
                    child:
                    ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _decks.length,
                      itemBuilder:(context, index){
                          return Padding(
                              padding: EdgeInsets.only(left: index == 0 ? 30 : 10, right: 10) ,
                              child: HomeDeckTile(
                                deckCoverPhotoUrl: _decks[index].coverPhoto,
                                titleOfDeck: _decks[index].title,
                                ownerOfDeck: _decks[index].deckOwnerName,
                                numberOfCards: _decks[index].flashcardCount,
                                onDelete: () {  },
                                onTap: () async {
                                  await Navigator.of(context).push(
                                    RouteGenerator.createRoute(
                                        ViewDeckPage(deck: _decks[index], filter: "MY_DECKS")),
                                  );

                                  setState(() {
                                    _initUserDecks(_user);
                                  });
                                },
                              )
                          );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Padding(
                    padding:EdgeInsets.only(left: 30),
                    child: Text(
                        'Explore',
                        style: TextStyle(
                            fontFamily: 'Fraiche',
                            fontSize: 30,
                            color: DeckColors.primaryColor,
                            fontWeight: FontWeight.bold)
                    ),
                  ),
                  if(_recoDecks.isNotEmpty)
                  SizedBox(
                    height: 150.0,
                    child:
                    ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _recoDecks.length,
                      itemBuilder:(context, index){
                        return Padding(
                            padding: EdgeInsets.only(left: index == 0 ? 30 : 10, right: 10) ,
                            child: HomeDeckTile(
                              titleOfDeck: _recoDecks[index].title,
                              ownerOfDeck: _recoDecks[index].deckOwnerName,
                              numberOfCards: _recoDecks[index].flashcardCount,
                              deckCoverPhotoUrl: _recoDecks[index].coverPhoto,
                              onDelete: () {  },
                              onTap: () {  },
                            )
                        );
                      },
                    ),
                  ),
                  if(_recoDecks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0),
                      child: IfCollectionEmpty(
                        hasIcon: false,
                        hasBackground: true,
                        ifCollectionEmptyText: 'No decks to recommend just yet! ',
                        ifCollectionEmptySubText:
                        'Explore decks to get recommendation',
                      ),
                    )
                ]
            ),
          )
      ),
      // SafeArea(
      //     top: true,
      //     bottom: false,
      //     left: true,
      //     right: true,
      //     minimum: const EdgeInsets.only(left: 20, right: 20),
      //     child:
      //
      //
      //     CustomScrollView(
      //       slivers: <Widget>[
      //         const SliverToBoxAdapter(
      //           child: Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [
      //                 Padding(
      //                   padding: EdgeInsets.only(top: 20.0),
      //                   child: Row(
      //                     children: [
      //                       Icon(
      //                        DeckIcons2.hat,
      //                         color: DeckColors.white,
      //                         size: 32,
      //                       ),
      //                     ],
      //                   ),
      //                 ),
      //               ]
      //           ),
      //         ),
      //         SliverToBoxAdapter(
      //           child: Column(
      //             crossAxisAlignment: CrossAxisAlignment.start,
      //             children: [
      //               Text(
      //                   greeting,
      //                   style: const TextStyle(
      //                       fontFamily: 'Fraiche',
      //                       fontSize: 60,
      //                       color: DeckColors.primaryColor,
      //                       fontWeight: FontWeight.bold)
      //               ),
      //               const Text(
      //                   'Let\'s be productive today as well!',
      //                   style: TextStyle(
      //                       fontFamily: 'Nunito-Bold',
      //                       fontSize: 16,
      //                       color: DeckColors.white,
      //                       )
      //               ),
      //             ],
      //           ),
      //         ),
      //
      //         const SliverToBoxAdapter(
      //           child: SizedBox(height: 30,),
      //         ),
      //         // const DeckSliverHeader(
      //         //   backgroundColor: Colors.transparent,
      //         //   headerTitle: "Let's be productive today as well!",
      //         //   textStyle: TextStyle(
      //         //     color: DeckColors.white,
      //         //     fontWeight: FontWeight.w300,
      //         //     fontSize: 16,
      //         //   ),
      //         //   isPinned: false,
      //         //   max: 50,
      //         //   min: 50,
      //         //   hasIcon: false,
      //         // ),
      //         const SliverToBoxAdapter(
      //           child: Column(
      //             crossAxisAlignment: CrossAxisAlignment.start,
      //             children: [
      //               Text(
      //                   'Upcoming Deadlines',
      //                   style: TextStyle(
      //                       fontFamily: 'Fraiche',
      //                       fontSize: 30,
      //                       color: DeckColors.primaryColor,
      //                       fontWeight: FontWeight.bold)
      //               ),
      //             ],
      //           ),
      //         ),
      //         const SliverToBoxAdapter(
      //           child: SizedBox(height: 30,),
      //         ),
      //         // const DeckSliverHeader(
      //         //   backgroundColor: Colors.transparent,
      //         //   headerTitle: "Upcoming Deadlines",
      //         //   textStyle: TextStyle(
      //         //     color: DeckColors.primaryColor,
      //         //     fontFamily: 'Fraiche',
      //         //     fontSize: 24,
      //         //   ),
      //         //   isPinned: false,
      //         //   max: 50,
      //         //   min: 50,
      //         //   hasIcon: false,
      //         // ),
      //
      //         if(taskToday.isEmpty)
      //           SliverToBoxAdapter(
      //             child: Container(
      //               padding: const EdgeInsets.all(30),
      //               decoration: const BoxDecoration(
      //                 color: DeckColors.white,
      //                   borderRadius: BorderRadius.all(Radius.circular(40)),
      //               ),
      //               child: IfCollectionEmpty(
      //                 hasIcon: false,
      //                 ifCollectionEmptyText: 'YIPEE! No upcoming deadlines! ',
      //                 ifCollectionEmptySubText:
      //                 'Now’s the perfect time to get ahead. Start adding new tasks and stay on top of your game!',
      //                 ifCollectionEmptyHeight: MediaQuery.of(context).size.height/5,
      //               ),
      //             )
      //           )
      //         else if (taskToday.isNotEmpty)
      //           SliverList(
      //           delegate: SliverChildBuilderDelegate(childCount: _tasks.length.clamp(0, 5),
      //               (context, index) {
      //             DateTime deadline = DateTime(_tasks[index].deadline.year,
      //                 _tasks[index].deadline.month, _tasks[index].deadline.day);
      //             DateTime notifyRange = DateTime(DateTime.now().year,
      //                     DateTime.now().month, DateTime.now().day)
      //                 .add(const Duration(days: 1));
      //             DateTime today = DateTime(DateTime.now().year,
      //                 DateTime.now().month, DateTime.now().day);
      //             if (!_tasks[index].isDone &&
      //                 deadline.isBefore(notifyRange) &&
      //                 deadline.isAtSameMomentAs(today)
      //                 ) {
      //               return
      //                 LayoutBuilder(
      //                   builder: (context, BoxConstraints constraints) {
      //                 return  DeckTaskTile(
      //                   title: _tasks[index].title,
      //                   deadline: TaskProvider.getNameDate(_tasks[index].deadline),
      //                   priority: _tasks[index].priority,
      //                   progressStatus: 'to do',
      //                   // title: tasks[index]['title'],
      //                   // deadline: _tasks[index].deadline.toString().split(" ")[0],
      //                   // priority: tasks[index]['priority'],
      //                   // progressStatus: tasks[index]['progressStatus'],
      //                   enableRetrieve: false,
      //                   onTap: () {
      //                     print("Clicked task tile!");
      //                     Navigator.push(
      //                       context,
      //                       RouteGenerator.createRoute(ViewTaskPage(task: _tasks[index], isEditable: false)),
      //                     );
      //                   }, onDelete: () {  },
      //                 );
      //               });
      //             } else {
      //               return const SizedBox();
      //             }
      //           }),
      //         ),
      //         const SliverToBoxAdapter(
      //           child: SizedBox(height: 30,),
      //         ),
      //         const SliverToBoxAdapter(
      //           child: Column(
      //             crossAxisAlignment: CrossAxisAlignment.start,
      //             children: [
      //               Text(
      //                   'Continue Learning',
      //                   style: TextStyle(
      //                       fontFamily: 'Fraiche',
      //                       fontSize: 30,
      //                       color: DeckColors.primaryColor,
      //                       fontWeight: FontWeight.bold)
      //               ),
      //             ],
      //           ),
      //         ),
      //
      //         // const DeckSliverHeader(
      //         //   backgroundColor: Colors.transparent,
      //         //   headerTitle: "Continue Learning",
      //         //   textStyle: TextStyle(
      //         //     color: DeckColors.primaryColor,
      //         //     fontFamily: 'Fraiche',
      //         //     fontSize: 24,
      //         //   ),
      //         //   isPinned: false,
      //         //   max: 50,
      //         //   min: 50,
      //         //   hasIcon: false,
      //         // ),
      //         const SliverToBoxAdapter(
      //           child: SizedBox(height: 30,),
      //         ),
      //         if (_decks.isEmpty)
      //           SliverToBoxAdapter(
      //               child: Container(
      //                 padding: EdgeInsets.all(30),
      //                 decoration: const BoxDecoration(
      //                   color: DeckColors.white,
      //                   borderRadius: BorderRadius.all(Radius.circular(40)),
      //                 ),
      //                 child: IfCollectionEmpty(
      //                   hasIcon: false,
      //                   ifCollectionEmptyText: 'No Recent Decks Yet!',
      //                   ifCollectionEmptySubText:
      //                   'Now’s the perfect time to get ahead. Create your own Deck now to keep learning.',
      //                   ifCollectionEmptyHeight: MediaQuery.of(context).size.height/5,
      //                 ),
      //               )
      //           )
      //         else if (_decks.isNotEmpty)
      //           SliverGrid(
      //               delegate: SliverChildBuilderDelegate(
      //                   childCount: _decks.length, (context, index) {
      //                 return LayoutBuilder(
      //                     builder: (context, BoxConstraints constraints) {
      //                   double cardWidth = constraints.maxWidth;
      //                   return HomeDeckTile(
      //                     deckName: _decks[index].title.toString(),
      //                     deckImageUrl: _decks[index].coverPhoto.toString(),
      //                     deckColor: DeckColors.white,
      //                     cardWidth: cardWidth - 8,
      //                     onPressed: () {
      //                       print('frck tile clicked');
      //                       Navigator.push(
      //                         context,
      //                         RouteGenerator.createRoute(
      //                             ViewDeckPage(deck: _decks[index])),
      //                       );
      //                     },
      //                   );
      //                 });
      //               }),
      //               gridDelegate:
      //                   const SliverGridDelegateWithFixedCrossAxisCount(
      //                 crossAxisCount: 2,
      //                 mainAxisSpacing: 10,
      //                 crossAxisSpacing: 10,
      //               )),
      //       ],
      //     )),
    );
  }
}
