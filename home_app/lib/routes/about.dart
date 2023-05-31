import 'package:flutter/material.dart';

class AboutRoute extends StatelessWidget {
  const AboutRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          transform: GradientRotation(-5 / 10),
          begin: Alignment.topCenter,
          end: Alignment(0.8, 1),
          colors: [
            Color(0xff003049),
            Color(0xffd62828),
          ],
          tileMode: TileMode.mirror,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              color: Colors.transparent,
              icon: const Icon(Icons.add_alert),
              tooltip: 'Show Snackbar',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('You found an easter egg'),
                  ),
                );
              },
            ),
          ],
          centerTitle: true,
          title: const Text('About section'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        'Home Smartify',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Contact me:',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.email,
                      color: Colors.white,
                    ),
                    title: Text('petrache.andrei1@gmail.com'),
                    textColor: Colors.white,
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Follow me:',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.link,
                      color: Colors.white,
                    ),
                    title: Text('Github: liviuq'),
                    textColor: Colors.white,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
