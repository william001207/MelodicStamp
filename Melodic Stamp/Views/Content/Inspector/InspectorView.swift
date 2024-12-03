//
//  InspectorView.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/24.
//

import CSFBAudioEngine
import Luminare
import SwiftUI

struct InspectorView: View {
    @Environment(\.luminareMinHeight) private var minHeight

    @Bindable var player: PlayerModel
    @Bindable var metadataEditor: MetadataEditorModel

    @State private var attachedPicturesHandler: AttachedPicturesHandlerModel =
        .init()

    @State private var isCoverPickerPresented: Bool = false
    @State private var chosenAttachedPictureType: AttachedPicture.`Type` =
        .frontCover

    var body: some View {
        if metadataEditor.hasEditableMetadata {
            AutoScrollView(.vertical) {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        attachedPicturesEditor()

                        AdaptableMusicCovers(
                            attachedPicturesHandler:
                                attachedPicturesHandler,
                            state: metadataEditor[
                                extracting: \.attachedPictures]
                        )
                        .padding(.horizontal, -16)
                        .contentMargins(
                            .horizontal, 16, for: .scrollIndicators)
                    }

                    LabeledSection {
                        generalEditor()
                    }

                    LabeledSection {
                        albumEditor()
                    } label: {
                        Text("Album")
                    }

                    LabeledSection {
                        trackAndDiscEditor()
                    } label: {
                        Text("Track and Disc")
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
                .safeAreaPadding(.top, 64)
                .safeAreaPadding(.bottom, 94)

                Spacer()
                    .frame(height: 150)
            }
            .contentMargins(.top, 64, for: .scrollIndicators)
            .contentMargins(.bottom, 94, for: .scrollIndicators)
        } else {
            InspectorExcerpt()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder private func attachedPicturesEditor() -> some View {
        HStack(alignment: .center, spacing: 0) {
            Text("Pictures")
                .foregroundStyle(.secondary)

            Spacer()

            LuminareSection(hasPadding: false) {
                HStack(spacing: 2) {
                    let state = metadataEditor[extracting: \.attachedPictures]
                    let types = attachedPicturesHandler.types(state: state)
                    let availableTypes = Set(AttachedPicture.allTypes)
                        .subtracting(types)

                    Button {
                        attachedPicturesHandler.remove(state: state)
                    } label: {
                        HStack {
                            Image(systemSymbol: .trashFill)
                            Text("Remove All")
                        }
                        .padding()
                    }
                    .buttonStyle(LuminareDestructiveButtonStyle())
                    .fixedSize(horizontal: true, vertical: false)
                    .disabled(types.isEmpty)

                    Menu {
                        ForEach(AttachedPictureCategory.allCases) { category in
                            let availableTypesInCategory =
                                availableTypes.intersection(category.allTypes)

                            Section {
                                ForEach(
                                    Array(availableTypesInCategory).sorted(
                                        by: <), id: \.self
                                ) { type in
                                    Button {
                                        chosenAttachedPictureType = type
                                        isCoverPickerPresented = true
                                    } label: {
                                        AttachedPictureTypeView(type: type)
                                    }
                                }
                            } header: {
                                AttachedPictureCategoryView(category: category)
                            }
                        }
                    } label: {
                        Image(systemSymbol: .plus)
                            .padding()
                    }
                    .buttonStyle(LuminareProminentButtonStyle())
                    .aspectRatio(1, contentMode: .fit)
                    .disabled(availableTypes.isEmpty)
                    .fileImporter(
                        isPresented: $isCoverPickerPresented,
                        allowedContentTypes: AttachedPicturesHandlerModel
                            .allowedContentTypes
                    ) { result in
                        switch result {
                        case .success(let url):
                            guard url.startAccessingSecurityScopedResource()
                            else { break }
                            defer { url.stopAccessingSecurityScopedResource() }

                            guard
                                let image = NSImage(contentsOf: url),
                                let attachedPicture = image.attachedPicture(
                                    of: chosenAttachedPictureType)
                            else { break }
                            attachedPicturesHandler.replace(
                                [attachedPicture], state: state)
                        case .failure:
                            break
                        }
                    }
                }
                .luminareMinHeight(minHeight)
                .frame(height: minHeight)
            }
            .luminareBordered(false)
            .luminareButtonMaterial(.ultraThin)
            .luminareSectionMasked(true)
            .luminareSectionMaxWidth(nil)
            .shadow(color: .black.opacity(0.5), radius: 32)
        }
    }

    @ViewBuilder private func generalEditor() -> some View {
        LabeledTextField("Title", text: metadataEditor[extracting: \.title])

        LabeledTextField("Artist", text: metadataEditor[extracting: \.artist])

        LabeledTextField(
            "Composer", text: metadataEditor[extracting: \.composer])
    }

    @ViewBuilder private func albumEditor() -> some View {
        LabeledTextField(
            "Album Title", text: metadataEditor[extracting: \.albumTitle])

        LabeledTextField(
            "Album Artist", text: metadataEditor[extracting: \.albumArtist])
    }

    @ViewBuilder private func trackAndDiscEditor() -> some View {
        LuminarePopover(arrowEdge: .top) {
            switch metadataEditor[extracting: \.bpm] {
            case let .fine(values):
                LuminareStepper(
                    value: .init {
                        CGFloat(values.current ?? .zero)
                    } set: { _ in
                        // do nothing
                    },
                    source: .infinite(),
                    indicatorSpacing: 16,
                    onRoundedValueChange: { _, newValue in
                        values.current = Int(newValue)
                    }
                )
            default:
                EmptyView()
            }
        } badge: {
            LabeledTextField(
                "BPM", state: metadataEditor[extracting: \.bpm], format: .number
            )
        }
        .luminarePopoverTrigger(.forceTouch)

        HStack {
            LabeledTextField(
                "No.", state: metadataEditor[extracting: \.trackNumber],
                format: .number, showsLabel: false
            )
            .frame(maxWidth: 72)

            Image(systemSymbol: .poweron)
                .imageScale(.large)
                .rotationEffect(.degrees(21))
                .frame(width: 4)
                .foregroundStyle(.placeholder)

            LabeledTextField(
                "Tracks", state: metadataEditor[extracting: \.trackTotal],
                format: .number)
        }

        HStack {
            LabeledTextField(
                "No.", state: metadataEditor[extracting: \.discNumber],
                format: .number, showsLabel: false
            )
            .frame(maxWidth: 72)

            Image(systemSymbol: .poweron)
                .imageScale(.large)
                .rotationEffect(.degrees(21))
                .frame(width: 4)
                .foregroundStyle(.placeholder)

            LabeledTextField(
                "Discs", state: metadataEditor[extracting: \.discTotal],
                format: .number)
        }
    }
}
