/// Ticket BLoC - State Management
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/ticket_entity.dart';
import '../../domain/usecases/ticket_usecases.dart';

// Events
abstract class TicketEvent extends Equatable {
  const TicketEvent();

  @override
  List<Object?> get props => [];
}

class FetchTicketsEvent extends TicketEvent {
  final String? userId;
  final String? role;

  const FetchTicketsEvent({this.userId, this.role});

  @override
  List<Object?> get props => [userId, role];
}

class FetchTicketDetailEvent extends TicketEvent {
  final String ticketId;

  const FetchTicketDetailEvent({required this.ticketId});

  @override
  List<Object?> get props => [ticketId];
}

class CreateTicketEvent extends TicketEvent {
  final String title;
  final String description;
  final List<({List<int> bytes, String name})>? attachmentFiles;

  const CreateTicketEvent({
    required this.title,
    required this.description,
    this.attachmentFiles,
  });

  @override
  List<Object?> get props => [title, description, attachmentFiles];
}

class UpdateTicketStatusEvent extends TicketEvent {
  final String ticketId;
  final String newStatus;

  const UpdateTicketStatusEvent({
    required this.ticketId,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [ticketId, newStatus];
}

class AssignTicketEvent extends TicketEvent {
  final String ticketId;
  final String assignedTo;

  const AssignTicketEvent({
    required this.ticketId,
    required this.assignedTo,
  });

  @override
  List<Object?> get props => [ticketId, assignedTo];
}

class AddTicketCommentEvent extends TicketEvent {
  final String ticketId;
  final String message;

  const AddTicketCommentEvent({
    required this.ticketId,
    required this.message,
  });

  @override
  List<Object?> get props => [ticketId, message];
}

class FetchTicketHistoryEvent extends TicketEvent {
  final String ticketId;

  const FetchTicketHistoryEvent({required this.ticketId});

  @override
  List<Object?> get props => [ticketId];
}

class FetchTicketStatisticsEvent extends TicketEvent {
  final String? userId;

  const FetchTicketStatisticsEvent({this.userId});

  @override
  List<Object?> get props => [userId];
}

class UploadTicketAttachmentEvent extends TicketEvent {
  final String ticketId;
  final List<int> fileBytes;
  final String fileName;

  const UploadTicketAttachmentEvent({
    required this.ticketId,
    required this.fileBytes,
    required this.fileName,
  });

  @override
  List<Object?> get props => [ticketId, fileBytes, fileName];
}

class DeleteTicketEvent extends TicketEvent {
  final String ticketId;

  const DeleteTicketEvent({required this.ticketId});

  @override
  List<Object?> get props => [ticketId];
}

// States
abstract class TicketState extends Equatable {
  const TicketState();

  @override
  List<Object?> get props => [];
}

class TicketInitial extends TicketState {
  const TicketInitial();
}

class TicketLoading extends TicketState {
  const TicketLoading();
}

class TicketSuccess extends TicketState {
  const TicketSuccess();
}

// Tickets List States
class TicketsLoaded extends TicketState {
  final List<TicketEntity> tickets;

  const TicketsLoaded({required this.tickets});

  @override
  List<Object?> get props => [tickets];
}

// Ticket Detail States
class TicketDetailLoaded extends TicketState {
  final TicketEntity ticket;

  const TicketDetailLoaded({required this.ticket});

  @override
  List<Object?> get props => [ticket];
}

// Ticket History States
class TicketHistoryLoaded extends TicketState {
  final List<TicketHistoryEntity> history;

  const TicketHistoryLoaded({required this.history});

  @override
  List<Object?> get props => [history];
}

// Statistics States
class TicketStatisticsLoaded extends TicketState {
  final Map<String, int> statistics;

  const TicketStatisticsLoaded({required this.statistics});

  @override
  List<Object?> get props => [statistics];
}

// Error State
class TicketError extends TicketState {
  final String message;

  const TicketError({required this.message});

  @override
  List<Object?> get props => [message];
}

// BLoC Implementation
class TicketBloc extends Bloc<TicketEvent, TicketState> {
  final CreateTicketUseCase createTicketUseCase;
  final GetTicketsUseCase getTicketsUseCase;
  final GetTicketDetailUseCase getTicketDetailUseCase;
  final UpdateTicketStatusUseCase updateTicketStatusUseCase;
  final AssignTicketUseCase assignTicketUseCase;
  final AddTicketCommentUseCase addTicketCommentUseCase;
  final GetTicketHistoryUseCase getTicketHistoryUseCase;
  final GetTicketStatisticsUseCase getTicketStatisticsUseCase;
  final UploadTicketAttachmentUseCase uploadTicketAttachmentUseCase;
  final DeleteTicketUseCase deleteTicketUseCase;

  TicketBloc({
    required this.createTicketUseCase,
    required this.getTicketsUseCase,
    required this.getTicketDetailUseCase,
    required this.updateTicketStatusUseCase,
    required this.assignTicketUseCase,
    required this.addTicketCommentUseCase,
    required this.getTicketHistoryUseCase,
    required this.getTicketStatisticsUseCase,
    required this.uploadTicketAttachmentUseCase,
    required this.deleteTicketUseCase,
  }) : super(const TicketInitial()) {
    on<FetchTicketsEvent>(_onFetchTickets);
    on<FetchTicketDetailEvent>(_onFetchTicketDetail);
    on<CreateTicketEvent>(_onCreateTicket);
    on<UpdateTicketStatusEvent>(_onUpdateTicketStatus);
    on<AssignTicketEvent>(_onAssignTicket);
    on<AddTicketCommentEvent>(_onAddTicketComment);
    on<FetchTicketHistoryEvent>(_onFetchTicketHistory);
    on<FetchTicketStatisticsEvent>(_onFetchTicketStatistics);
    on<UploadTicketAttachmentEvent>(_onUploadTicketAttachment);
    on<DeleteTicketEvent>(_onDeleteTicket);
  }

  Future<void> _onFetchTickets(
    FetchTicketsEvent event,
    Emitter<TicketState> emit,
  ) async {
    emit(const TicketLoading());
    try {
      final tickets = await getTicketsUseCase(
        userId: event.userId,
        role: event.role,
      );
      emit(TicketsLoaded(tickets: tickets));
    } catch (e) {
      emit(TicketError(message: e.toString()));
    }
  }

  Future<void> _onFetchTicketDetail(
    FetchTicketDetailEvent event,
    Emitter<TicketState> emit,
  ) async {
    emit(const TicketLoading());
    try {
      final ticket = await getTicketDetailUseCase(ticketId: event.ticketId);
      if (ticket != null) {
        emit(TicketDetailLoaded(ticket: ticket));
      } else {
        emit(const TicketError(message: 'Ticket tidak ditemukan'));
      }
    } catch (e) {
      emit(TicketError(message: e.toString()));
    }
  }

  Future<void> _onCreateTicket(
    CreateTicketEvent event,
    Emitter<TicketState> emit,
  ) async {
    emit(const TicketLoading());
    try {
      final ticket = await createTicketUseCase(
        title: event.title,
        description: event.description,
      );
      
      // Upload attachments if any
      if (event.attachmentFiles != null && event.attachmentFiles!.isNotEmpty) {
        for (final file in event.attachmentFiles!) {
          await uploadTicketAttachmentUseCase(
            ticketId: ticket.id,
            fileBytes: file.bytes,
            fileName: file.name,
          );
        }
      }
      
      emit(const TicketSuccess());
      // Refresh tickets list
      add(const FetchTicketsEvent());
    } catch (e) {
      emit(TicketError(message: e.toString()));
    }
  }

  Future<void> _onUpdateTicketStatus(
    UpdateTicketStatusEvent event,
    Emitter<TicketState> emit,
  ) async {
    try {
      await updateTicketStatusUseCase(
        ticketId: event.ticketId,
        newStatus: event.newStatus,
      );
      emit(const TicketSuccess());
      // Refresh detail
      add(FetchTicketDetailEvent(ticketId: event.ticketId));
    } catch (e) {
      emit(TicketError(message: e.toString()));
    }
  }

  Future<void> _onAssignTicket(
    AssignTicketEvent event,
    Emitter<TicketState> emit,
  ) async {
    try {
      await assignTicketUseCase(
        ticketId: event.ticketId,
        assignedTo: event.assignedTo,
      );
      emit(const TicketSuccess());
      add(FetchTicketDetailEvent(ticketId: event.ticketId));
    } catch (e) {
      emit(TicketError(message: e.toString()));
    }
  }

  Future<void> _onAddTicketComment(
    AddTicketCommentEvent event,
    Emitter<TicketState> emit,
  ) async {
    try {
      await addTicketCommentUseCase(
        ticketId: event.ticketId,
        message: event.message,
      );
      emit(const TicketSuccess());
      add(FetchTicketHistoryEvent(ticketId: event.ticketId));
    } catch (e) {
      emit(TicketError(message: e.toString()));
    }
  }

  Future<void> _onFetchTicketHistory(
    FetchTicketHistoryEvent event,
    Emitter<TicketState> emit,
  ) async {
    try {
      final history = await getTicketHistoryUseCase(ticketId: event.ticketId);
      emit(TicketHistoryLoaded(history: history));
    } catch (e) {
      emit(TicketError(message: e.toString()));
    }
  }

  Future<void> _onFetchTicketStatistics(
    FetchTicketStatisticsEvent event,
    Emitter<TicketState> emit,
  ) async {
    try {
      final stats = await getTicketStatisticsUseCase(userId: event.userId);
      emit(TicketStatisticsLoaded(statistics: stats));
    } catch (e) {
      emit(TicketError(message: e.toString()));
    }
  }

  Future<void> _onUploadTicketAttachment(
    UploadTicketAttachmentEvent event,
    Emitter<TicketState> emit,
  ) async {
    try {
      await uploadTicketAttachmentUseCase(
        ticketId: event.ticketId,
        fileBytes: event.fileBytes,
        fileName: event.fileName,
      );
      emit(const TicketSuccess());
    } catch (e) {
      emit(TicketError(message: e.toString()));
    }
  }

  Future<void> _onDeleteTicket(
    DeleteTicketEvent event,
    Emitter<TicketState> emit,
  ) async {
    try {
      await deleteTicketUseCase(ticketId: event.ticketId);
      emit(const TicketSuccess());
      add(const FetchTicketsEvent());
    } catch (e) {
      emit(TicketError(message: e.toString()));
    }
  }
}
