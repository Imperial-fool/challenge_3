import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'ball.dart';
import 'paddle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class BallHolder {
  double dir = 1;
  double x_spd = 0.5;
  double y_spd = 1;

  double x;
  double y;
  Color color;

  ball? b;
  BallHolder(this.x, this.y, this.color) {
    b = ball(x, y, color);
  }
  updateBall() => b = ball(x, y, color);
  double getX() => x;
  double getY() => y;
  void modX(val) {
    x += val;
    updateBall();
  }

  void modY(val) {
    print(val * dir);
    y += val * dir;
    updateBall();
  }

  void modXY(val) {
    y += val * y_spd * dir;
    x += val * ((2 * x_spd) - 1);
    updateBall();
  }
}

class Player {
  int score = 0;
  double x;
  double y;
  double mov_spd;
  double size = 2;
  Color color;
  paddle? p;
  Player(this.x, this.y, this.color, this.mov_spd) {
    p = paddle(x, y, color, size);
  }
  updatePlayer() => p = paddle(x, y, color, size);
  getX() => x;

  modX(val, maxX) {
    var x_ = 2 * (val / maxX) - 1;
    if (x_ != x) {
      if (x_ > 0) {
        if (x < 1) {
          x += mov_spd;
        }
      }
      if (x_ <= 0) {
        if (x > -1) {
          x -= mov_spd;
        }
      }
      updatePlayer();
    }
  }

  getsize() => size;
  modSize(val) {
    if (size < 4) size += val;
    updatePlayer();
  }

  getMovSpd() => mov_spd;
  modMovSpd(val) {
    if (mov_spd < 10) mov_spd += val;
  }

  modScore() => score++;
  getScore() => score;
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const move(),
    );
  }
}

class move extends StatefulWidget {
  const move({Key? key}) : super(key: key);

  @override
  State<move> createState() => _moveState();
}

class _moveState extends State<move> with TickerProviderStateMixin {
  bool started = false;
  bool lost = false;
  bool ai_lost = false;

  Player player = Player(0, 0.9, Color.fromARGB(255, 0, 255, 8), 0.01);
  Player ai = Player(0, -0.9, Color.fromARGB(255, 255, 0, 0), 0.02);
  BallHolder ball = BallHolder(0, 0, Color.fromARGB(255, 255, 255, 255));

  var speed = 2;
  var tapLocation = 0.0;
  var last_score = 0;
  var multipler = 1;
  var count = 0;
  var count_m = 0;

  var holding = false;
  late final Ticker _ticker;

  _onTapDown(TapDownDetails details) {
    tapLocation = details.globalPosition.dx;
    holding = true;
  }

  _onTapUp(TapUpDetails details) {
    tapLocation = details.globalPosition.dx;
    holding = false;
  }

  void moveBall() {
    setState(() {
      ball.modXY(0.01 * speed);
    });
  }

  Container getScore() {
    return Container(
      child: Text('You: ${player.getScore()}',
          style: GoogleFonts.pressStart2p(
              color: const Color.fromARGB(255, 0, 255, 8), fontSize: 10)),
    );
  }

  Container getScoreAi() {
    return Container(
        child: Text('AI: ${ai.getScore()}',
            style: GoogleFonts.pressStart2p(
                color: const Color.fromARGB(255, 0, 255, 8), fontSize: 10)));
  }

  Container getPlayer() {
    return Container(child: player.p);
  }

  Container getAi() {
    return Container(child: ai.p);
  }

  Container getBall() {
    return Container(child: ball.b);
  }

  movePlayer() {
    if (holding == true) {
      player.modX(tapLocation, MediaQuery.of(context).size.width);
    }
  }

  moveAi() {
    if (!(ball.x > (ai.x - 0.1 * ai.size) && ball.x < (ai.x + 0.1 * ai.size))) {
      if (ball.x < ai.x) {
        ai.modX(0, MediaQuery.of(context).size.width);
        return;
      }
      if (ball.x > ai.x) {
        ai.modX(MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.width);
        return;
      }
    }
  }

  bool collisionBall() {
    if (ball.y >= 0.85) {
      if (ball.x > (player.x - 0.1 * player.size) &&
          ball.x < (player.x + 0.1 * player.size)) {
        player.score++;
        ball.x_spd = math.Random().nextDouble();
        if (ball.x_spd < 0.1) {
          ball.x_spd += 0.15;
        }
        if (ball.x_spd > 0.9) {
          ball.x_spd -= 0.15;
        }
        ball.y_spd = 1 - ball.x_spd;
        ball.dir = -1;
        return true;
      }
    }
    if (ball.y <= -0.85) {
      if (ball.x > (ai.x - 0.1 * ai.size) && ball.x < (ai.x + 0.1 * ai.size)) {
        ai.score++;
        ball.x_spd = math.Random().nextDouble();
        if (ball.x_spd < 0.2) {
          ball.x_spd += 0.15;
        }
        if (ball.x_spd > 0.8) {
          ball.x_spd -= 0.15;
        }
        ball.y_spd = 1 - ball.x_spd;
        ball.dir = 1;
        return true;
      }
    }
    if (ball.x >= 1 || ball.x <= -1) {
      if (ball.x_spd > 0.5) {
        ball.x_spd = math.Random().nextDouble() / 2;
        if (ball.x_spd < 0.2) {
          ball.x_spd += 0.15;
        }
        ball.y_spd = 1 - ball.x_spd;
        return true;
      } else if (ball.x_spd <= 0.5) {
        ball.x_spd = math.Random().nextDouble() / 2 + 0.5;

        if (ball.x_spd > 0.8) {
          ball.x_spd -= 0.15;
        }
        ball.y_spd = 1 - ball.x_spd;
        return true;
      }
      //if this works, my black magic knows no bounds
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      if (started) {
        moveBall();
        movePlayer();
        moveAi();
        collisionBall();
        if (ball.y > 0.95 || ball.y < -0.95) {
          bool winner = false;
          if (ball.y < -0.95) winner = true;
          resetGame(winner);
        }
      }
    });
    _ticker.start();
  }

  resetGame(bool winner) {
    tapLocation = 0.0;

    last_score = player.score;
    player = Player(0, 0.9, Color.fromARGB(255, 0, 255, 8), 0.01);
    ai = Player(0, -0.9, Color.fromARGB(255, 255, 0, 0), 0.01);
    ball = BallHolder(0, 0, Color.fromARGB(255, 255, 255, 255));

    multipler = 1;
    count = 0;
    count_m = 0;

    holding = false;
    started = false;

    if (winner) {
      ai_lost = true;
    } else {
      lost = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> l = [];
    l.add(getPlayer());
    l.add(getAi());
    l.add(getBall());

    return GestureDetector(
        onTap: () {
          if (!started) {
            started = true;
            print('started: ' + started.toString());
            lost = false;
            ai_lost = false;
          }
        },
        onTapDown: (TapDownDetails details) => _onTapDown(details),
        onTapUp: (TapUpDetails details) => _onTapUp(details),
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            actions: [
              Expanded(
                  flex: 3,
                  child: Center(
                    child: ((() {
                      if (!lost && !ai_lost) {
                        return Row(
                          children: [
                            const SizedBox(width: 10),
                            getScore(),
                            const SizedBox(
                              width: 10,
                            ),
                            getScoreAi(),
                          ],
                        );
                      }
                      if (!started && (lost || ai_lost)) {
                        return Text('SCORE: $last_score',
                            style: GoogleFonts.pressStart2p(
                                color: const Color.fromARGB(255, 0, 255, 8),
                                fontSize: 20));
                      }
                    }())),
                  )),
            ],
          ),
          body: (() {
            if (started) return Stack(children: l);
            if (!started && (lost && !ai_lost)) {
              return Center(
                child: Text('YOU LOSE! \n\n Tap to Play Again!',
                    style: GoogleFonts.pressStart2p(
                      color: const Color.fromARGB(255, 0, 255, 8),
                      fontSize: 25,
                    )),
              );
            }
            if (!started && ai_lost) {
              return Center(
                child: Text('YOU WIN! \n\n Tap to Play Again!',
                    style: GoogleFonts.pressStart2p(
                        color: const Color.fromARGB(255, 0, 255, 8),
                        fontSize: 25)),
              );
            }
            if (!started) {
              return Center(
                child: Text(
                  'Tap To Play',
                  style: GoogleFonts.pressStart2p(
                      color: const Color.fromARGB(255, 0, 255, 8),
                      fontSize: 25),
                ),
              );
            }
          }()),
        ));
  }
}
