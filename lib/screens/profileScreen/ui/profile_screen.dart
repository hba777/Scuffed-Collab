import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scuffed_collab/helper/dailogs.dart';
import 'package:scuffed_collab/models/UserModel.dart';
import 'package:scuffed_collab/screens/auth/login_screen.dart';
import 'package:scuffed_collab/screens/homeScreen/homeBloc/home_bloc.dart';

import '../../../main.dart';
import '../profileBloc/profile_bloc.dart';

class ProfileScreen extends StatelessWidget {
  final UserModel user;
  final HomeBloc homeBloc;
  final _formKey = GlobalKey<FormState>(); // Add a GlobalKey for the Form
  String? _image;

  ProfileScreen({super.key, required this.user, required this.homeBloc});

  @override
  Widget build(BuildContext context) {

    return BlocProvider(
      create: (context) =>
      ProfileBloc()
        ..add(ProfileInitialEvent(user: user)),
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listenWhen: (previous, current) => current is ProfileActionState,
        buildWhen: (previous, current) => current is! ProfileActionState,
        listener: (context, state) {
          if (state is ProfileLogoutButtonNavigationState) {
            Navigator.pop(context);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
            );
          } else if (state is ProfileUpdatePfPState) {
            Dialogs.showSnackBar(context, 'Profile Updated Successfully');
          } else if (state is ProfileErrorState) {
            Dialogs.showSnackBar(
                context, 'Could Not Log Out, Check internet connection');
          }
        },
        builder: (context, state) {
          switch (state.runtimeType) {
            case ProfileSuccessState:
              return GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Scaffold(
                  appBar: AppBar(
                    leading: IconButton(
                      onPressed: () {
                        if(_image != null) {
                          homeBloc.add(HomeInitialEvent());
                        }
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: mq.width * .05,
                      ),
                    ),
                    title: const Text(
                      "Profile Screen",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  floatingActionButton: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: FloatingActionButton.extended(
                      backgroundColor: const Color(0xFF111111),
                      onPressed: () {
                        context.read<ProfileBloc>().add(ProfileLogoutEvent());
                        Dialogs.showProgressBar(context);
                      },
                      label: Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: mq.width * .04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ),
                  body: Form(
                    key: _formKey, // Use the GlobalKey for the form
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 100),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              width: mq.width,
                              height: mq.height * .03,
                            ),
                            BlocBuilder<ProfileBloc, ProfileState>(
                              builder: (context, state) {
                                if(state is ProfileUpdatePfpImageState){
                                  _image = state.image;
                                }
                                return Stack(
                                  children: [
                                    //Profile Picture
                                    _image != null
                                        ? ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          mq.height * .1),
                                      child: Center(
                                        child: Image.file(
                                          //Import dartIO not html
                                          File(_image!),
                                          width: mq.height * .2,
                                          height: mq.height * .2,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                        : ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          mq.height * .1),
                                      child: CachedNetworkImage(
                                        width: mq.height * .2,
                                        height: mq.height * .2,
                                        fit: BoxFit.cover,
                                        imageUrl: user.Image,
                                        placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: MaterialButton(
                                        onPressed: () {
                                          _showBottomSheet(context);
                                        },
                                        color: const Color(0xFF111111),
                                        elevation: 1,
                                        shape: const CircleBorder(),
                                        child: Icon(
                                          size: mq.width * .05,
                                          Icons.edit,
                                          color: Colors.greenAccent,
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              },
                            ),
                            SizedBox(height: mq.height * .03),
                            Text(
                              user.Email,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: mq.width * .035,
                              ),
                            ),
                            SizedBox(height: mq.height * .03),
                            _buildTextField(
                                'Name',
                                user.Name,
                                Icon(
                                  CupertinoIcons.person,
                                  color: Colors.white,
                                  size: mq.width * .05,
                                ),
                                context,
                                true),
                            SizedBox(height: mq.height * .03),
                            _buildTextField(
                                'About',
                                user.About,
                                Icon(CupertinoIcons.info,
                                    color: Colors.white, size: mq.width * .05),
                                context,
                                false),
                            SizedBox(height: mq.height * .03),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF111111),
                                  shape: const StadiumBorder(),
                                  minimumSize:
                                  Size(mq.width * .5, mq.height * .06)),
                              onPressed: () {
                                // Handle Update Profile Logic Here
                                // Check if the form is valid
                                if (_formKey.currentState!.validate()) {
                                  // Save the form fields' data (this will trigger the onSaved callbacks)
                                  _formKey.currentState!.save();

                                  // Show a snackbar or progress indicator if necessary
                                  Dialogs.showSnackBar(
                                      context, 'Updating profile...');

                                  // The ProfileBloc handles the name and about updates.
                                  // The passing of context to textField and onSaved properties contribute to this
                                }
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.greenAccent,
                              ),
                              label: Text(
                                'UPDATE',
                                style: TextStyle(
                                    fontSize: mq.width * .04,
                                    color: Colors.greenAccent),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            default:
              return const SizedBox();
          }
        },
      ),
    );
  }

  Widget _buildTextField(String label, String initialValue, Icon icon,
      BuildContext context, bool isName) {
    return SizedBox(
      width: mq.width * 1.25,
      child: TextFormField(
        style: TextStyle(
          color: Colors.white,
          fontSize: mq.width * .034,
        ),
        initialValue: initialValue,
        onSaved: (val) {
          if (isName) {
            context
                .read<ProfileBloc>()
                .add(ProfileEditNameEvent(newName: val ?? ''));
          } else {
            context
                .read<ProfileBloc>()
                .add(ProfileEditAboutEvent(newAbout: val ?? ''));
          }
        },
        validator: (val) =>
        val != null && val.isNotEmpty ? null : 'Required Field',
        decoration: InputDecoration(
          prefixIcon: icon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(mq.width * .1),
          ),
          hintText: label,
          label: Text(label),
          labelStyle: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: const Color(0xFF1e1e1e),
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(
            top: mq.height * .04,
            bottom: mq.height * .05,
          ),
          children: [
            Text(
              'Pick Profile Picture',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: mq.width * .04,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: mq.height * .02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111111),
                    fixedSize: Size(mq.width * .2, mq.height * .2),
                    shape: const CircleBorder(),
                  ),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery, imageQuality: 80);

                    if (image != null) {
                      _image = image.path;
                      context.read<ProfileBloc>().add(ProfileEditGalleryPfpEvent(newPfp: image));
                    }
                  },
                  child: const Icon(Icons.image, color: Colors.greenAccent),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111111),
                    fixedSize: Size(mq.width * .2, mq.height * .2),
                    shape: const CircleBorder(),
                  ),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                        source: ImageSource.camera, imageQuality: 80);

                    if (image != null) {
                      _image = image.path;
                      context.read<ProfileBloc>().add(ProfileEditGalleryPfpEvent(newPfp: image));
                    }
                  },
                  child: const Icon(CupertinoIcons.camera, color: Colors.greenAccent),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
