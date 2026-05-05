import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/providers/challenge_provider.dart';
import 'package:frontend/core/providers/user_provider.dart';
import 'package:frontend/core/services/friend_service.dart';
import 'package:frontend/core/providers/chat_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class Friends extends StatefulWidget {
  const Friends({super.key});

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  final TextEditingController _uuidController = TextEditingController();
  bool _isLoading = true;
  String? _loadError;
  List<Map<String, dynamic>> _friendRequests = [];
  List<Map<String, dynamic>> _friends = [];
  String? _currentUserId;
  String? _currentUsername;

  @override
  void initState() {
    super.initState();
    _loadFriendsData();
  }

  @override
  void dispose() {
    _uuidController.dispose();
    super.dispose();
  }

  Future<void> _loadFriendsData() async {
    try {
      final data = await UserProvider.loadUser();
      final user = data['user'];
      final userId = (user is Map) ? user['id']?.toString() : null;
      final username = (user is Map) ? user['username']?.toString() : null;

      if (userId == null || userId.isEmpty) {
        throw Exception('Missing user id');
      }

      final requestsData = await FriendService.getFriendRequests(userId);
      final friendsData = await FriendService.getFriendsList(userId);

      final requests = requestsData['requests'];
      final friends = friendsData['friends'];

      if (!mounted) {
        return;
      }

      setState(() {
        _friendRequests = requests is List
            ? List<Map<String, dynamic>>.from(requests)
            : [];
        _friends = friends is List
            ? List<Map<String, dynamic>>.from(friends)
            : [];
        _isLoading = false;
        _loadError = null;
        _currentUserId = userId;
        _currentUsername = username;
      });

    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _loadError = error.toString();
      });
    }
  }

  Future<String> _getCurrentUserId() async {
    if (_currentUserId != null && _currentUserId!.isNotEmpty) {
      return _currentUserId!;
    }
    final data = await UserProvider.loadUser();
    final user = data['user'];
    final userId = (user is Map) ? user['id']?.toString() : null;
    if (userId == null || userId.isEmpty) {
      throw Exception('Missing user id');
    }
    _currentUserId = userId;
    return userId;
  }

  Future<void> _challengeFriend(Map<String, dynamic> friend) async {
    try {
      final targetId = friend['friend_id']?.toString();
      if (targetId == null || targetId.isEmpty) {
        throw Exception('Không tìm thấy id bạn bè');
      }
      final challengeProvider =
          Provider.of<ChallengeProvider>(context, listen: false);
      await challengeProvider.sendChallenge(targetId);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Loi: ${error.toString()}')),
      );
    }
  }

  Future<void> _openChatWithFriend(Map<String, dynamic> friend) async {
    try {
      final targetId = friend['friend_id']?.toString();
      final targetName = friend['username']?.toString() ?? 'Không rõ';
      if (targetId == null || targetId.isEmpty) {
        throw Exception('Không tìm thấy id bạn bè');
      }
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      if (chatProvider.currentUserId.isEmpty) {
        await chatProvider.reinitialize();
      }

      if (!mounted) {
        return;
      }

      context.go(
        '/chat',
        extra: {
          'targetUserId': targetId,
          'targetUsername': targetName,
        },
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${error.toString()}')),
      );
    }
  }

  Future<void> _acceptRequest(String friendRecordId) async {
    try {
      final userId = await _getCurrentUserId();
      await FriendService.acceptRequest(friendRecordId, userId);
      await _loadFriendsData();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${error.toString()}')),
      );
    }
  }

  Future<void> _rejectRequest(String friendRecordId) async {
    try {
      final userId = await _getCurrentUserId();
      await FriendService.rejectRequest(friendRecordId, userId);
      await _loadFriendsData();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Loi: ${error.toString()}')),
      );
    }
  }

  bool _isUuidLike(String value) {
    final trimmed = value.trim();
    final uuidLike = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidLike.hasMatch(trimmed);
  }

  Future<void> _sendFriendRequestByUuid() async {
    final uuid = _uuidController.text.trim();
    if (uuid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập UUID.')),
      );
      return;
    }
    if (!_isUuidLike(uuid)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Định dạng UUID không hợp lệ.')),
      );
      return;
    }

    try {
      final data = await UserProvider.loadUser();
      final user = data['user'];
      final requesterId = (user is Map) ? user['id']?.toString() : null;

      if (requesterId == null || requesterId.isEmpty) {
        throw Exception('Missing requester id');
      }

      await FriendService.requestByUuid(requesterId, uuid);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Da gui loi moi den $uuid')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Loi: ${error.toString()}')),
      );
    }
  }

  Widget _buildAvatar(String username) {
    final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(100.0),
        color: const Color(0xFFBEBFBF),
      ),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          initial,
          style: TextStyle(fontSize: 20.0),
        ),
      ),
    );
  }

  Widget _buildRequestItem(Map<String, dynamic> request) {
    final username = request['username']?.toString() ?? 'Khong ro';
    final friendRecordId = request['friend_record_id']?.toString();
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFDEDEDE),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: _buildAvatar(username),
                ),
                Padding(
                  padding: EdgeInsetsGeometry.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Loi moi ket ban'),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: friendRecordId == null
                      ? null
                      : () => _acceptRequest(friendRecordId),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: Icon(FontAwesomeIcons.check),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                ),
                ElevatedButton(
                  onPressed: friendRecordId == null
                      ? null
                      : () => _rejectRequest(friendRecordId),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: Icon(FontAwesomeIcons.x),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendItem(Map<String, dynamic> friend) {
    final username = friend['username']?.toString() ?? 'Khong ro';
    final wins = friend['total_wins']?.toString() ?? '0';
    final losses = friend['total_losses']?.toString() ?? '0';
    final draws = friend['total_draws']?.toString() ?? '0';
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFDEDEDE),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: _buildAvatar(username),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsetsGeometry.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('${wins}W / ${losses}L / ${draws}D'),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _challengeFriend(friend),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Thách đấu'),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                ),
                ElevatedButton(
                  onPressed: () => _openChatWithFriend(friend),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.black,
                  ),
                  child: Icon(FontAwesomeIcons.comment),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.black,
                    fixedSize: Size(100, 25),
                  ),
                  child: PopupMenuButton<int>(
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<int>>[
                      PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.userXmark),
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                10.0,
                                0.0,
                                10.0,
                                0.0,
                              ),
                            ),
                            Text('Huy ket ban'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.ban,
                              color: Colors.red,
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                10.0,
                                0.0,
                                10.0,
                                0.0,
                              ),
                            ),
                            Text(
                              'Chan',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tìm bạn theo UUID',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: TextField(
                          controller: _uuidController,
                          decoration: InputDecoration(
                            hintText: 'Nhập UUID',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            prefixIcon: Icon(FontAwesomeIcons.magnifyingGlass),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _sendFriendRequestByUuid,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Gửi lời mời kết bạn'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isLoading) ...[
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ] else if (_loadError != null) ...[
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text('Tải dữ liệu thất bại: $_loadError'),
                ),
              ] else ...[
                Card(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.userPlus, color: Colors.blue),
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                10.0,
                                0.0,
                                10.0,
                                0.0,
                              ),
                            ),
                            Text(
                              'Lời mời kết bạn',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                10.0,
                                0.0,
                                10.0,
                                0.0,
                              ),
                            ),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue,
                              ),
                              child: Text(
                                _friendRequests.length.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_friendRequests.isEmpty)
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text('Không có lời mời chờ'),
                        )
                      else
                        Column(
                          children:
                              _friendRequests.map(_buildRequestItem).toList(),
                        ),
                    ],
                  ),
                ),
                Card(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Bạn bè (${_friends.length})',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      if (_friends.isEmpty)
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text('Chưa có bạn bè'),
                        )
                      else
                        Column(
                          children: _friends.map(_buildFriendItem).toList(),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
