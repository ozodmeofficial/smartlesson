import 'package:flutter/material.dart';

import '../services/runner.dart';

// ------------------------------------------------------------------ theory

sealed class Block {
  const Block();
}

/// Oddiy matn. `**qalin**` va `` `kod` `` qo'llanadi.
class TextBlock extends Block {
  final String md;
  const TextBlock(this.md);
}

class BulletsBlock extends Block {
  final List<String> items;
  const BulletsBlock(this.items);
}

class CodeBlock extends Block {
  final String code;
  final String? caption;
  final bool runnable;
  const CodeBlock(this.code, {this.caption, this.runnable = true});
}

enum NoteKind { info, warning, tip }

class NoteBlock extends Block {
  final String md;
  final NoteKind kind;
  const NoteBlock(this.md, {this.kind = NoteKind.info});
}

class TableBlock extends Block {
  final List<String> header;
  final List<List<String>> rows;
  const TableBlock(this.header, this.rows);
}

/// Katta, esda qoladigan tasviriy o'xshatish.
class AnalogyBlock extends Block {
  final String emoji;
  final String title;
  final String md;
  const AnalogyBlock(this.emoji, this.title, this.md);
}

/// "Eslab qolish kaliti" — mnemonika.
class MnemonicBlock extends Block {
  final String md;
  const MnemonicBlock(this.md);
}

/// Stringni munchoqlar (indekslar bilan) ko'rinishida chizadi.
class BeadsBlock extends Block {
  final String text;
  final int? from, to; // ajratib ko'rsatish oralig'i [from, to)
  const BeadsBlock(this.text, {this.from, this.to});
}

class QuickCheck {
  final String question;
  final String? code;
  final List<String> options;
  final int correct;
  final String explain;
  const QuickCheck(this.question, this.options, this.correct, this.explain, {this.code});
}

class Section {
  final String id;
  final String emoji;
  final String title;
  final List<Block> blocks;
  final QuickCheck? check;
  const Section(this.id, this.emoji, this.title, this.blocks, {this.check});
}

// -------------------------------------------------------------------- quiz

class QuizQ {
  final String question;
  final String? code;
  final List<String> options;
  final int correct;
  final String explain;
  final bool codeOptions; // variantlar kod ko'rinishida chiqsinmi
  const QuizQ(this.question, this.options, this.correct, this.explain, {this.code, this.codeOptions = false});
}

// ------------------------------------------------------------- flashcards

class FlashCard {
  final String id;
  final String front;
  final String back;
  final String? frontCode;
  final String? backCode;
  const FlashCard(this.id, this.front, this.back, {this.frontCode, this.backCode});
}

// ------------------------------------------------------------ memory game

class MemoryPair {
  final String a; // odatda kod
  final String b; // ma'nosi / natijasi
  final String explain;
  const MemoryPair(this.a, this.b, this.explain);
}

// -------------------------------------------------------------- code task

class TaskVerdict {
  final bool ok;
  final String message;
  const TaskVerdict(this.ok, this.message);
  static const pass = TaskVerdict(true, "Ajoyib! Hammasi to'g'ri ishladi.");
}

/// Tekshiruvchi: foydalanuvchi kodini kerakli kiritmalar (stdin) bilan `run`
/// orqali ishga tushirib, natijani baholaydi.
typedef TaskChecker = Future<TaskVerdict> Function(String code, Future<RunResult> Function(String stdin) run);

class CodeTask {
  final String id;
  final String title;
  final String description;
  final String starter;
  final String solution;
  final List<String> hints;
  final TaskChecker check;
  final bool usesInput;
  const CodeTask({
    required this.id,
    required this.title,
    required this.description,
    required this.starter,
    required this.solution,
    required this.hints,
    required this.check,
    this.usesInput = false,
  });
}

// ------------------------------------------------------------------ lesson

enum LabKind { memoryLab, nameGame, typeSorter, truthyGame, sliceLab, sliceNinja }

class Lesson {
  final String id;
  final int number;
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
  final Color color2;
  final String intro;
  final List<String> goals;
  final List<Section> sections;
  final List<LabKind> labs;
  final List<CodeTask> tasks;
  final List<MemoryPair> pairs;
  final List<QuizQ> quiz;
  final List<FlashCard> cards;
  final List<String> summary;

  const Lesson({
    required this.id,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.color2,
    required this.intro,
    required this.goals,
    required this.sections,
    required this.labs,
    required this.tasks,
    required this.pairs,
    required this.quiz,
    required this.cards,
    required this.summary,
  });
}
