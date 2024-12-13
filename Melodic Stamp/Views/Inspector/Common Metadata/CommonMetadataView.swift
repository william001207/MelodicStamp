//
//  CommonMetadataView.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/24.
//

import CSFBAudioEngine
import Luminare
import SwiftUI

struct CommonMetadataView: View {
    @Environment(\.luminareMinHeight) private var minHeight

    @Bindable var metadataEditor: MetadataEditorModel

    @State private var attachedPicturesHandler: AttachedPicturesHandlerModel =
        .init()

    @State private var isCoverPickerPresented: Bool = false
    @State private var chosenAttachedPictureType: AttachedPicture.`Type` =
        .frontCover

    var body: some View {
        if metadataEditor.isVisible {
            AutoScrollView(.vertical) {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        attachedPicturesEditor()

                        AdaptableMusicCovers(
                            attachedPicturesHandler:
                            attachedPicturesHandler,
                            entries: metadataEditor[
                                extracting: \.attachedPictures
                            ]
                        ) {
                            Spacer()
                                .frame(height: 8)

                            Divider()
                                .padding(.horizontal, 16)
                        }
                        .padding(.horizontal, -16)
                        .contentMargins(
                            .horizontal, 16, for: .scrollIndicators
                        )
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
                }
                .padding(.horizontal)
                // don't use `contentMargins()` for content as it breaks progressive blurs
                .safeAreaPadding(.top, 64)
                .safeAreaPadding(.bottom, 94)

                Spacer()
                    .frame(height: 150)
            }
            .contentMargins(.top, 64, for: .scrollIndicators)
            .contentMargins(.bottom, 94, for: .scrollIndicators)
        } else {
            CommonMetadataExcerpt()
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
                    let entries = metadataEditor[extracting: \.attachedPictures]
                    let types = attachedPicturesHandler.types(of: entries)
                    let availableTypes = Set(AttachedPicture.allTypes)
                        .subtracting(types)

                    Button(role: .destructive) {
                        attachedPicturesHandler.remove(entries: entries)
                    } label: {
                        HStack {
                            Image(systemSymbol: .trashFill)
                            Text("Remove All")
                        }
                        .padding()
                    }
                    .buttonStyle(.luminareProminent)
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
                    .aspectRatio(1, contentMode: .fit)
                    .disabled(availableTypes.isEmpty)
                    .fileImporter(
                        isPresented: $isCoverPickerPresented,
                        allowedContentTypes: AttachedPicturesHandlerModel
                            .allowedContentTypes
                    ) { result in
                        switch result {
                        case let .success(url):
                            guard url.startAccessingSecurityScopedResource()
                            else { break }
                            defer { url.stopAccessingSecurityScopedResource() }

                            guard
                                let image = NSImage(contentsOf: url),
                                let attachedPicture = image.attachedPicture(
                                    of: chosenAttachedPictureType)
                            else { break }
                            attachedPicturesHandler.replace(
                                [attachedPicture], entries: entries
                            )
                        case .failure:
                            break
                        }
                    }
                }
                .buttonStyle(.luminare)
                .luminareMinHeight(minHeight)
                .frame(height: minHeight)
            }
            .luminareBordered(false)
            .luminareButtonMaterial(.ultraThin)
            .luminareSectionMasked(true)
            .luminareSectionMaxWidth(nil)
            .shadow(color: .black.opacity(0.25), radius: 32)
        }
    }

    @ViewBuilder private func generalEditor() -> some View {
        LabeledTextField("Title", text: metadataEditor[extracting: \.title])

        LabeledTextField("Artist", text: metadataEditor[extracting: \.artist])

        LabeledTextField(
            "Composer", text: metadataEditor[extracting: \.composer]
        )

        LabeledTextField("Genre", text: metadataEditor[extracting: \.genre])
    }

    @ViewBuilder private func albumEditor() -> some View {
        LabeledTextField(
            "Album Title", text: metadataEditor[extracting: \.albumTitle]
        )

        LabeledTextField(
            "Album Artist", text: metadataEditor[extracting: \.albumArtist]
        )
    }

    @ViewBuilder private func trackAndDiscEditor() -> some View {
        LuminarePopover(arrowEdge: .top) {
            if let binding = metadataEditor[extracting: \.bpm].projectedValue {
                LuminareStepper(
                    value: .init {
                        CGFloat(binding.wrappedValue ?? .zero)
                    } set: { _ in
                        // do nothing
                    },
                    source: .infinite(),
                    indicatorSpacing: 16,
                    onRoundedValueChange: { _, newValue in
                        binding.wrappedValue = Int(newValue)
                    }
                )
            } else {
                EmptyView()
            }
        } badge: {
            LabeledTextField(
                "BPM", entries: metadataEditor[extracting: \.bpm], format: .number
            )
        }
        .luminarePopoverTrigger(.forceTouch)

        HStack {
            LabeledTextField(
                "No.", entries: metadataEditor[extracting: \.trackNumber],
                format: .number, showsLabel: false
            )
            .frame(maxWidth: 72)

            Image(systemSymbol: .poweron)
                .imageScale(.large)
                .rotationEffect(.degrees(21))
                .frame(width: 4)
                .foregroundStyle(.placeholder)

            LabeledTextField(
                "Tracks", entries: metadataEditor[extracting: \.trackTotal],
                format: .number
            )
        }

        HStack {
            LabeledTextField(
                "No.", entries: metadataEditor[extracting: \.discNumber],
                format: .number, showsLabel: false
            )
            .frame(maxWidth: 72)

            Image(systemSymbol: .poweron)
                .imageScale(.large)
                .rotationEffect(.degrees(21))
                .frame(width: 4)
                .foregroundStyle(.placeholder)

            LabeledTextField(
                "Discs", entries: metadataEditor[extracting: \.discTotal],
                format: .number
            )
        }
    }
}
