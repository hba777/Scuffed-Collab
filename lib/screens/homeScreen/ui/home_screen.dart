import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:scuffed_collab/helper/dailogs.dart';
import 'package:scuffed_collab/helper/my_date_util.dart';
import 'package:scuffed_collab/repos/FirebaseApi.dart';
import 'package:scuffed_collab/screens/homeScreen/homeBloc/home_bloc.dart';
import 'package:scuffed_collab/screens/profileScreen/ui/profile_screen.dart';
import 'package:scuffed_collab/screens/projectScreen/projectBloc/project_details_bloc.dart';
import 'package:scuffed_collab/screens/projectScreen/ui/project_screen.dart';
import 'package:scuffed_collab/widgets/ProjectCard.dart';
import 'package:scuffed_collab/widgets/TextFieldWidget.dart';

import '../../../main.dart';
import '../../../models/ProjectsModel.dart';
import '../../projectCreationScreen/projectCreationBloc/project_bloc.dart';
import '../../projectCreationScreen/ui/project_entry_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeBloc homeBloc;
  late TextEditingController projectController;
  final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  List<Projects> filteredProjects = []; // List to hold filtered projects

  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async{
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    homeBloc.add(HomeInitialEvent());
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }
  @override
  void initState() {
    super.initState();
    projectController = TextEditingController();
    homeBloc = HomeBloc();
    homeBloc.add(HomeInitialEvent());

    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');
      if (FirebaseApi.auth.currentUser != null) {
        if (message.toString().contains('pause')) {
          homeBloc.add(HomeLifecycleChangeEvent(lifecycleState: 'pause'));
        } else if (message.toString().contains('resume')) {
          homeBloc.add(HomeLifecycleChangeEvent(lifecycleState: 'resume'));
        }
      }
      return Future.value(message);
    });
  }

  @override
  void dispose() {
    super.dispose();
    projectController.dispose();
  }

  void _filterProjects(String query) {
    homeBloc.add(HomeFilterProjectsEvent(query));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      bloc: homeBloc,
      listenWhen: (previous, current) => current is HomeActionState,
      buildWhen: (previous, current) => current is! HomeActionState,
      listener: (context, state) {
        if (state is HomeLifecyclePauseState) {
          homeBloc.add(HomeUpdateActiveStatusEvent(isOnline: false));
          log('\n offline false');
        } else if (state is HomeLifecycleStartState) {
          homeBloc.add(HomeUpdateActiveStatusEvent(isOnline: true));
        } else if (state is HomeProfileNavigationState) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => ProfileScreen(user: state.user, homeBloc: homeBloc)));
        } else if (state is HomeProjectNavigationState) {
          Navigator.push(context, MaterialPageRoute(builder: (_) =>
              BlocProvider(
                create: (context) => ProjectBloc()..add(ProjectInitialEvent()),
                child: ProjectEntryScreen(),
              )));
        } else if (state is HomeProjectClickedNavigationState) {
          Navigator.push(context, MaterialPageRoute(builder: (_) =>
              BlocProvider(
                create: (context) => ProjectDetailsBloc()..add(ProjectDetailsInitialEvent(project: state.clickedProject)),
                child: ProjectScreen(project: state.clickedProject, homeBloc: homeBloc,),
              )));
        } else if (state is HomeErrorState) {
          Dialogs.showSnackBar(context, state.error);
        }
      },
      builder: (context, state) {
        switch (state.runtimeType) {
          case HomeLoadingState:
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                backgroundColor: Colors.greenAccent,
              ),
            );
          case HomeSuccessState:
            final successState = state as HomeSuccessState;
            filteredProjects = successState.projects; // Initialize the filtered list
            return Scaffold(
                appBar: AppBar(
                  leading: Image.asset(
                    'assets/images/Headphone.png',
                    color: Colors.white,
                  ),
                  actions: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: mq.width * .02),
                      child: InkWell(
                        onTap: () {
                          homeBloc.add(HomeProfileButtonEvent(user: successState.user));
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(mq.width * .7),
                          child: CachedNetworkImage(
                            width: mq.width * .11,
                            placeholder: (context, string) =>
                            const CircularProgressIndicator(
                              backgroundColor: Colors.greenAccent,
                            ),
                            imageUrl: successState.user.Image,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                body: SmartRefresher(
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  enablePullDown: true,
                  header: const ClassicHeader(
                    refreshingIcon: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent), // Customize indicator color
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: mq.height * .04),
                          child: Center(
                            child: RoundedTextField(
                              padding: EdgeInsets.symmetric(
                                  horizontal: mq.width * .05,
                                  vertical: mq.height * .014),
                              fillColor: const Color(0xFF3c3c3c),
                              borderColor: const Color(0xFF1e1e1e),
                              width: mq.width * .8,
                              height: mq.height * .055,
                              controller: projectController,
                              hintText: 'Search for projects...',
                              onChanged: _filterProjects, // Update on text change
                            ),
                          ),
                        ),
                        SizedBox(height: mq.height * .02),
                        // List of Projects
                        Column(
                          children: [
                            ListView.builder(
                              // Dynamic Size of List
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(), // To avoid nested scrolling conflicts
                              itemCount: filteredProjects.isNotEmpty
                                  ? filteredProjects.length + 1 // Add 1 for the "Add Project" card
                                  : successState.projects.length + 1, // Add 1 for the "Add Project" card
                              itemBuilder: (context, index) {
                                if (index < (filteredProjects.isNotEmpty ? filteredProjects.length : successState.projects.length)) {
                                  // Regular project cards
                                  final project = filteredProjects.isNotEmpty
                                      ? filteredProjects[index]
                                      : successState.projects[index];
                                  return InkWell(
                                    onTap: () {
                                      // Pass Project to Next Screen
                                      homeBloc.add(HomeProjectClickedEvent(clickedProject: project));
                                    },
                                    child: ProjectCard(
                                      projectTitle: project.title,
                                      projectDescription: project.description,
                                      projectCreatedAt: MyDateUtil.getFormattedDateTime(
                                        context: context,
                                        time: project.createdAt,
                                      ),
                                    ),
                                  );
                                } else {
                                  // "Add Project" card
                                  return Padding(
                                    padding: EdgeInsets.symmetric(horizontal: mq.width *.04),
                                    child: SizedBox(
                                      height: mq.height * .12,
                                      width: mq.width * .8,
                                      child: Card(
                                        color: const Color(0xFF111111),
                                        surfaceTintColor: const Color(0xFF111111),
                                        child: Center(
                                          child: IconButton(
                                            onPressed: () {
                                              homeBloc.add(HomeCreateProjectEvent());
                                            },
                                            icon: Icon(
                                              CupertinoIcons.add,
                                              size: mq.width * .08,
                                              color: Colors.greenAccent,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),
                ));
          default:
            return const SizedBox();
        }
      },
    );
  }
}
