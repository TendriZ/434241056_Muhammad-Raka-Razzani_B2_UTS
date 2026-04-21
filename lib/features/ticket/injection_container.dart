/// Dependency Injection Setup untuk Ticket Feature
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/datasources/ticket_remote_datasource.dart';
import 'data/repositories/ticket_repository_impl.dart';
import 'domain/repositories/ticket_repository.dart';
import 'domain/usecases/ticket_usecases.dart';
import 'presentation/bloc/ticket_bloc.dart';

final getIt = GetIt.instance;

void setupTicketDependencies() {
  // Get Supabase instance
  final supabaseClient = Supabase.instance.client;

  // Register Data Sources
  getIt.registerSingleton<TicketRemoteDataSource>(
    TicketRemoteDataSourceImpl(supabaseClient: supabaseClient),
  );

  // Register Repositories
  getIt.registerSingleton<TicketRepository>(
    TicketRepositoryImpl(
      remoteDataSource: getIt<TicketRemoteDataSource>(),
    ),
  );

  // Register Use Cases
  getIt.registerSingleton<CreateTicketUseCase>(
    CreateTicketUseCase(repository: getIt<TicketRepository>()),
  );

  getIt.registerSingleton<GetTicketsUseCase>(
    GetTicketsUseCase(repository: getIt<TicketRepository>()),
  );

  getIt.registerSingleton<GetTicketDetailUseCase>(
    GetTicketDetailUseCase(repository: getIt<TicketRepository>()),
  );

  getIt.registerSingleton<UpdateTicketStatusUseCase>(
    UpdateTicketStatusUseCase(repository: getIt<TicketRepository>()),
  );

  getIt.registerSingleton<AssignTicketUseCase>(
    AssignTicketUseCase(repository: getIt<TicketRepository>()),
  );

  getIt.registerSingleton<AddTicketCommentUseCase>(
    AddTicketCommentUseCase(repository: getIt<TicketRepository>()),
  );

  getIt.registerSingleton<GetTicketHistoryUseCase>(
    GetTicketHistoryUseCase(repository: getIt<TicketRepository>()),
  );

  getIt.registerSingleton<GetTicketStatisticsUseCase>(
    GetTicketStatisticsUseCase(repository: getIt<TicketRepository>()),
  );

  getIt.registerSingleton<UploadTicketAttachmentUseCase>(
    UploadTicketAttachmentUseCase(repository: getIt<TicketRepository>()),
  );

  getIt.registerSingleton<DeleteTicketUseCase>(
    DeleteTicketUseCase(repository: getIt<TicketRepository>()),
  );

  // Register BLoC
  getIt.registerSingleton<TicketBloc>(
    TicketBloc(
      createTicketUseCase: getIt<CreateTicketUseCase>(),
      getTicketsUseCase: getIt<GetTicketsUseCase>(),
      getTicketDetailUseCase: getIt<GetTicketDetailUseCase>(),
      updateTicketStatusUseCase: getIt<UpdateTicketStatusUseCase>(),
      assignTicketUseCase: getIt<AssignTicketUseCase>(),
      addTicketCommentUseCase: getIt<AddTicketCommentUseCase>(),
      getTicketHistoryUseCase: getIt<GetTicketHistoryUseCase>(),
      getTicketStatisticsUseCase: getIt<GetTicketStatisticsUseCase>(),
      uploadTicketAttachmentUseCase: getIt<UploadTicketAttachmentUseCase>(),
      deleteTicketUseCase: getIt<DeleteTicketUseCase>(),
    ),
  );
}
