import 'package:flutter/material.dart';
import '../models/ProjectsModel.dart';

class ProjectCard extends StatelessWidget {
  final String projectTitle; // The project to display
  final String projectDescription;
  final String projectCreatedAt;

  const ProjectCard({Key? key, required this.projectTitle, required this.projectDescription, required this.projectCreatedAt,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: mq.width *.04, vertical: mq.height *.005),
      height: mq.height * .127,
      width: mq.width * .8,
      child: Card(
        color: const Color(0xFF111111),
        surfaceTintColor: const Color(0xFF111111),
        child: Padding(
          padding: EdgeInsets.all(mq.width *.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Created At
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Project title at the start
                  Expanded(
                    child: Text(
                      projectTitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: mq.width *.04,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Created at with justified alignment
                  Text(
                    projectCreatedAt,
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: mq.width *.03,
                    ),
                  ),
                ],
              ),
              SizedBox(height: mq.height *.02),
              // Description below the title
              Text(
                projectDescription,
                maxLines: 2, // Limit description to 2 lines
                overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: mq.width *.035,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
