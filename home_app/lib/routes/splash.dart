import 'package:flutter/material.dart';

import 'main_menu.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      // color of the background, bean will change
      // it s color based on this
      backgroundColor: const Color(0xff3e2ca6),
      body: SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            Positioned(
              top: -50,
              left: 0,
              child: Container(
                width: width,
                height: 400,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/bean.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(
              top: -100,
              left: 0,
              child: Container(
                width: width,
                height: 400,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/bean.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(
              top: -150,
              left: 0,
              child: Container(
                width: width,
                height: 400,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/bean.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 80.0, 100.0, 20.0),
                  child: Text(
                    "Welcome",
                    style: TextStyle(
                      color: Colors.white.withOpacity(1),
                      fontSize: 55,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "Your home. Your control.",
                    style: TextStyle(
                        color: Colors.white.withOpacity(.7),
                        height: 1.4,
                        fontSize: 20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: FloatingActionButton.extended(
                    label: const Text(
                      'Start exploring',
                    ),
                    backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                    icon: const Icon(
                      Icons.start_rounded,
                      size: 24.0,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainMenu(),
                        ),
                      ),
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
