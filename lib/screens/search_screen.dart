import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:instagram/screens/profile_screen.dart';
import 'package:velocity_x/velocity_x.dart';

import '../utils/colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  RxBool isShowUsers = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Form(
          child: TextFormField(
            controller: searchController,
            decoration: const InputDecoration(
                labelText: 'Search',
                //  hintText: 'Search',
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                )),
            onFieldSubmitted: (String _) {
              setState(() {
                isShowUsers.value = true;
              });
            },
          )
              .box
              .height(40)
              .rounded
              .padding(EdgeInsets.all(
                10,
              ))
              .width(context.screenWidth - 40)
              .color(Color.fromARGB(179, 87, 87, 87))
              .make(),
        ),
      ),
      body: Obx(
        () => isShowUsers.value
            ? FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .where(
                      'username',
                      isGreaterThanOrEqualTo: searchController.text.trim(),
                    )
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    // Handle the error gracefully, for example:
                    return const Center(
                      child: Text('Error fetching data'),
                    );
                  }

                  final docs = snapshot.data?.docs;
                  if (docs == null || docs.isEmpty) {
                    return const Center(
                      child: Text('No users found.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var snap = docs[index];
                      return InkWell(
                        onTap: () {
                          Get.to(
                            () => ProfileScreen(
                              uid: snap['uid'],
                            ),
                            transition: Transition.leftToRight,
                          );
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                // snap['postUrl'] != null
                                //     ? NetworkImage(snap['postUrl'])
                                //         as ImageProvider<Object>
                                //     :
                                NetworkImage(
                              'https://i.stack.imgur.com/l60Hf.png',
                            ),
                            radius: 16,
                          ),
                          title: Text(snap['username']),
                        ),
                      );
                    },
                  );
                },
              )
            : FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                future: FirebaseFirestore.instance
                    .collection('posts')
                    .orderBy('datePublished')
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    // Handle the error gracefully, for example:
                    return const Center(
                      child: Text('Error fetching data'),
                    );
                  }

                  final docs = snapshot.data?.docs;
                  if (docs == null || docs.isEmpty) {
                    return const Center(
                      child: Text('No posts found.'),
                    );
                  }

                  return MasonryGridView.count(
                    crossAxisCount: 3,
                    itemCount: docs.length,
                    itemBuilder: (context, index) => Image.network(
                      docs[index]['postUrl'],
                      fit: BoxFit.cover,
                    ),
                    mainAxisSpacing: 4.0,
                    crossAxisSpacing: 4.0,
                  );
                },
              ),
      ),
    );
  }
}
