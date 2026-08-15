import '../models/song.dart';

class MusicLibraryData {
  static const List<Song> songs = [
    Song(
      id: '1',
      title: 'BASYO MAYA',
      artist: 'Local',
      audioUrl: 'asset://audio/BASYO_MAYA(128k).mp3',
      folders: ['Lok', 'Favourite'],
    ),

    Song(
      id: '2',
      title: 'Gauri',
      artist: 'Local',
      audioUrl: 'asset://audio/Gauri.mp3',
      folders: ['Lok'],
    ),

    Song(
      id: '3',
      title: 'Nuwakote Yo Jhilke Keto',
      artist: 'Local',
      audioUrl: 'asset://audio/nuwakote_yo_jhilke.mp3',
      folders: ['Lok'],
    ),

    Song(
      id: '4',
      title: 'Krishna Bhajan',
      artist: 'Ibsal Sanjyal',
      audioUrl:
          'https://res.cloudinary.com/gl3ydn8a/video/upload/Krishna_Bhajan___%E0%A4%95%E0%A5%83%E0%A4%B7%E0%A5%8D%E0%A4%A3_%E0%A4%A4%E0%A4%BF%E0%A4%AE%E0%A5%80%E0%A4%B2%E0%A4%BE%E0%A4%88_%E0%A4%B0%E0%A4%BE%E0%A4%A7%E0%A4%BE_%E0%A4%B8%E0%A5%81%E0%A4%B9%E0%A4%BE%E0%A4%95%E0%A5%8B___%E0%A4%A8%E0%A5%87%E0%A4%AA%E0%A4%BE%E0%A4%B2%E0%A5%80_%E0%A4%95%E0%A5%83%E0%A4%B7%E0%A5%8D%E0%A4%A3_%E0%A4%AD%E0%A4%9C%E0%A4%A8___Ibsal_Sanjyal___Ashok_Pandey..mp3',
      folders: ['Bhajan'],
    ),
    Song(
      id: '5',
      title: 'Shanti Jagau',
      artist: 'shanti jagau',
      audioUrl:
          'https://res.cloudinary.com/gl3ydn8a/video/upload/znsmdf50cvlq9xbibdlo.mp3',
      folders: ['Bhajan'],
    ),
    Song(
      id: '6',
      title: 'Badulki Kukka',
      artist: 'shanti jagau',
      audioUrl:
          'https://res.cloudinary.com/gl3ydn8a/video/upload/rzg3dygo3gfku7auhr8o.mp3',
      folders: ['Lok'],
    ),
    Song(
      id: '7',
      title: 'Authi Chino Xa',
      artist: 'shanti jagau',
      audioUrl:
          'https://res.cloudinary.com/gl3ydn8a/video/upload/vpio0edamyo9er4crlp2.mp3',
      folders: ['Lok'],
    ),
  ];
}
