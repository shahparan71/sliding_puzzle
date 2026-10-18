import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

void main() {
  final slideWav = generateSlideSound();
  File('assets/sounds/slide.wav').writeAsBytesSync(slideWav);
  print('Generated assets/sounds/slide.wav: ${slideWav.length} bytes');

  final winWav = generateWinSound();
  File('assets/sounds/success.wav').writeAsBytesSync(winWav);
  print('Generated assets/sounds/success.wav: ${winWav.length} bytes');
}

Uint8List buildWavHeader(int dataLength, int sampleRate) {
  final buffer = ByteData(44);
  // RIFF
  buffer.setUint8(0, 0x52); // R
  buffer.setUint8(1, 0x49); // I
  buffer.setUint8(2, 0x46); // F
  buffer.setUint8(3, 0x46); // F
  buffer.setUint32(4, 36 + dataLength, Endian.little);
  // WAVE
  buffer.setUint8(8, 0x57);  // W
  buffer.setUint8(9, 0x41);  // A
  buffer.setUint8(10, 0x56); // V
  buffer.setUint8(11, 0x45); // E
  // fmt
  buffer.setUint8(12, 0x66); // f
  buffer.setUint8(13, 0x6D); // m
  buffer.setUint8(14, 0x74); // t
  buffer.setUint8(15, 0x20); // ' '
  buffer.setUint32(16, 16, Endian.little); // SubChunk1Size (16 for PCM)
  buffer.setUint16(20, 1, Endian.little);  // AudioFormat (1 for PCM)
  buffer.setUint16(22, 1, Endian.little);  // NumChannels (1 mono)
  buffer.setUint32(24, sampleRate, Endian.little); // SampleRate
  buffer.setUint32(28, sampleRate * 2, Endian.little); // ByteRate (SampleRate * NumChannels * BitsPerSample/8)
  buffer.setUint16(32, 2, Endian.little);  // BlockAlign (NumChannels * BitsPerSample/8)
  buffer.setUint16(34, 16, Endian.little); // BitsPerSample (16 bits)
  // data
  buffer.setUint8(36, 0x64); // d
  buffer.setUint8(37, 0x61); // a
  buffer.setUint8(38, 0x74); // t
  buffer.setUint8(39, 0x61); // a
  buffer.setUint32(40, dataLength, Endian.little);
  return buffer.buffer.asUint8List();
}

Uint8List generateSlideSound() {
  const sampleRate = 44100;
  const durationSec = 0.11;
  final numSamples = (sampleRate * durationSec).toInt();
  final pcm = ByteData(numSamples * 2);

  final random = Random(42);
  for (var i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final progress = i / numSamples;
    
    // Frequency sweeps down: 380 Hz down to 140 Hz
    final freq = 380.0 * (1.0 - progress * 0.65);
    
    // Wood resonant tone + subtle wood tap noise
    final sine = sin(2 * pi * freq * t);
    final harmonic = 0.35 * sin(2 * pi * (freq * 2.3) * t);
    final noise = (random.nextDouble() * 2 - 1) * 0.15 * exp(-progress * 20);

    // Natural attack and decay
    final attack = (i < 120) ? (i / 120.0) : 1.0;
    final decay = exp(-progress * 14.0);
    final env = attack * decay;

    final sample = ((sine + harmonic + noise) * env * 22000).clamp(-32768, 32767).toInt();
    pcm.setInt16(i * 2, sample, Endian.little);
  }

  final header = buildWavHeader(numSamples * 2, sampleRate);
  final result = Uint8List(header.length + pcm.lengthInBytes);
  result.setRange(0, header.length, header);
  result.setRange(header.length, result.length, pcm.buffer.asUint8List());
  return result;
}

Uint8List generateWinSound() {
  const sampleRate = 44100;
  const durationSec = 0.85;
  final numSamples = (sampleRate * durationSec).toInt();
  final pcm = ByteData(numSamples * 2);

  // Arpeggio notes: C5 (523.25), E5 (659.25), G5 (783.99), C6 (1046.50)
  final notes = [
    (0.00, 0.18, 523.25),
    (0.12, 0.22, 659.25),
    (0.24, 0.26, 783.99),
    (0.36, 0.50, 1046.50),
  ];

  final rawSamples = Float64List(numSamples);

  for (final note in notes) {
    final startT = note.$1;
    final dur = note.$2;
    final freq = note.$3;

    final startIdx = (startT * sampleRate).toInt();
    final endIdx = min(numSamples, ((startT + dur) * sampleRate).toInt());

    for (var i = startIdx; i < endIdx; i++) {
      final t = (i - startIdx) / sampleRate;
      final progress = t / dur;

      final fundamental = sin(2 * pi * freq * t);
      final harmonic2 = 0.4 * sin(4 * pi * freq * t);
      final harmonic3 = 0.2 * sin(6 * pi * freq * t);

      final attack = (t < 0.008) ? (t / 0.008) : 1.0;
      final decay = exp(-progress * 4.5);
      final env = attack * decay;

      rawSamples[i] += (fundamental + harmonic2 + harmonic3) * env * 0.45;
    }
  }

  for (var i = 0; i < numSamples; i++) {
    final sample = (rawSamples[i] * 28000).clamp(-32768, 32767).toInt();
    pcm.setInt16(i * 2, sample, Endian.little);
  }

  final header = buildWavHeader(numSamples * 2, sampleRate);
  final result = Uint8List(header.length + pcm.lengthInBytes);
  result.setRange(0, header.length, header);
  result.setRange(header.length, result.length, pcm.buffer.asUint8List());
  return result;
}
