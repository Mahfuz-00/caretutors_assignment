import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/service/background_wrapper.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/notes_provider.dart';
import '../widgets/note_card.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/note_entity.dart';
import '../widgets/note_card_placeholder.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final isSearching = ref.read(noteSearchProvider).isNotEmpty;
      if (!isSearching && _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(paginatedNotesProvider.notifier).fetchMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notesState = ref.watch(paginatedNotesProvider);
    final searchQuery = ref.watch(noteSearchProvider);
    final searchAsync = ref.watch(searchResultsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final bool isSearching = searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              final currentMode = ref.read(themeModeProvider);
              ref.read(themeModeProvider.notifier).state =
              currentMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
            },
            icon: Icon(
              ref.watch(themeModeProvider) == ThemeMode.light
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () => ref.read(authControllerProvider.notifier).logout(),
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
              label: const Text("Log Out", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: BaseBackground(
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Text(
                    "My Insights",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        fontSize: 32,
                        letterSpacing: -1.5
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                    child: TextField(
                      onChanged: (val) => ref.read(noteSearchProvider.notifier).state = val,
                      decoration: InputDecoration(
                        hintText: "Search everything...",
                        hintStyle: TextStyle(
                            color: Colors.black,
                        ),
                        prefixIcon: Icon(Icons.search_rounded, color: colorScheme.primary.withOpacity(0.5)),
                        filled: true,
                        fillColor: colorScheme.primary.withOpacity(0.05),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                ],
              ),
            ),

           if (isSearching)
              searchAsync.when(
                data: (results) => results.isEmpty
                    ? const SliverFillRemaining(child: Center(child: Text("No matches found.")))
                    : _buildGrid(results, ref),
                loading: () => SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) => const NoteCardPlaceholder(),
                      childCount: 6, // show 6 placeholders
                    ),
                  ),
                ),
                error: (e, _) => const SliverFillRemaining(child: Center(child: Text("Error fetching search results."))),
              )
            else
              notesState.isLoading
                  ? SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      delegate: SliverChildBuilderDelegate(
                            (context, index) => const NoteCardPlaceholder(),
                        childCount: 6,
                      ),
                    ),
                  )
                  : notesState.notes.isEmpty
                  ? const SliverFillRemaining(child: Center(child: Text("No insights yet.")))
                  : _buildGrid(notesState.notes, ref),

            if (!isSearching && notesState.isFetchingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator.adaptive()),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-note'),
        backgroundColor: colorScheme.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("Insight", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildGrid(List<NoteEntity> notes, WidgetRef ref) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final note = notes[index];
            return NoteCard(
              key: ValueKey(note.id),
              note: note,
              onTap: () => context.push('/note-details', extra: note),
              onDelete: () => ref.read(notesControllerProvider.notifier).deleteNote(note.id),
            );
          },
          childCount: notes.length,
        ),
      ),
    );
  }
}